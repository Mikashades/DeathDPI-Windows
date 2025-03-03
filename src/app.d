import std.stdio;
import std.conv;
import std.random;
import std.concurrency;
import std.algorithm;
import std.string;
import std.array;
import std.format;
import std.file;
import std.path;
import core.thread;
import core.atomic;
import core.sys.windows.windows;
import windivert;
import config;

shared bool running = true;

struct Config {
    bool fragment_http = true;
    bool fragment_https = true;
    bool modify_ttl = true;
    int min_ttl = 3;
    bool random_http_header = true;
    bool fragment_tcp = true;
    uint fragment_size = 2;
    bool reverse_tcp = true;
    bool wrong_seq = true;
    bool wrong_chksum = true;
    bool wrong_http = true;
    bool split_pos = true;
    uint split_pos_value = 12;
    bool fake_rst = true;
    bool auto_ttl = true;
    uint auto_ttl_min = 3;
    uint auto_ttl_max = 10;
    bool blacklist = true;
    string[] blacklist_hosts;
    bool dnsv4_redirect = false;
    string dnsv4_addr = "1.1.1.1";
    bool ipv6_support = false;
    bool https_tampering = true;
    bool packet_fragmentation = true;
    uint max_packet_size = 1500;
    bool tcp_tampering = true;
    bool udp_tampering = false;
    bool icmp_tampering = false;
    string[] whitelist_hosts;
    bool logging = true;
    string log_file = "deathdpi.log";
    uint log_level = 1;
    bool statistics = true;
    uint stats_interval = 60;
    bool auto_update = false;
    string update_url = "";
    bool gui_support = false;
}

enum string[] HTTP_METHODS = ["GET", "POST", "HEAD", "PUT", "DELETE", "OPTIONS", "CONNECT"];
enum string[] HTTP_VERSIONS = ["HTTP/1.1", "HTTP/1.0"];

void fragmentTcpPacket(ubyte[] packet, size_t fragment_size, ref WINDIVERT_IPHDR* ip_header, ref WINDIVERT_TCPHDR* tcp_header) {
    if (packet.length <= fragment_size) return;

    size_t data_offset = (ip_header.HdrLength * 4) + (tcp_header.HdrLength * 4);
    size_t data_length = packet.length - data_offset;

    if (data_length > fragment_size) {
        packet.length = data_offset + fragment_size;
    }
}

void modifyHttpHeader(ubyte[] packet, size_t offset) {
    string random_method = HTTP_METHODS[uniform(0, $)];
    string random_version = HTTP_VERSIONS[uniform(0, $)];
    
    string random_header = format("X-Random: %d\r\n", uniform(0, int.max));

    if (offset + random_header.length < packet.length) {
        memmove(packet.ptr + offset + random_header.length, 
                packet.ptr + offset, 
                packet.length - offset);
        memcpy(packet.ptr + offset, 
               random_header.ptr, 
               random_header.length);
    }
}

ubyte calculateOptimalTTL(shared Config* config) {
    if (config.auto_ttl) {
        return cast(ubyte)uniform(config.auto_ttl_min, config.auto_ttl_max + 1);
    }
    return cast(ubyte)config.min_ttl;
}

void processPacket(HANDLE handle, shared Config* config) {
    enum MAXBUF = 0xFFFF;
    auto packet = new ubyte[MAXBUF];
    WINDIVERT_ADDRESS addr;
    UINT packet_len;

    while (atomicLoad(running)) {
        if (!WinDivertRecv(handle, packet.ptr, MAXBUF, &addr, &packet_len)) {
            continue;
        }

        auto ip_header = cast(WINDIVERT_IPHDR*)packet.ptr;
        auto tcp_header = cast(WINDIVERT_TCPHDR*)(packet.ptr + (ip_header.HdrLength * 4));
        bool is_http = false;

        if (ntohs(tcp_header.DstPort) == 80 || ntohs(tcp_header.DstPort) == 443) {
            is_http = true;

            if (config.modify_ttl) {
                ip_header.TTL = calculateOptimalTTL(config);
            }

            if (config.random_http_header) {
                tcp_header.Window = cast(UINT16)(uniform(0, 65535));
            }

            if (config.wrong_seq) {
                tcp_header.SeqNum += uniform(1, 1000);
            }

            if (config.wrong_chksum) {
                tcp_header.Checksum = cast(UINT16)(uniform(0, 65535));
            }

            if (config.wrong_http && ntohs(tcp_header.DstPort) == 80) {
                size_t data_offset = (ip_header.HdrLength * 4) + (tcp_header.HdrLength * 4);
                modifyHttpHeader(packet[0..packet_len], data_offset);
            }

            if (config.fake_rst) {
                auto rst_packet = packet[0..packet_len].dup;
                auto rst_tcp = cast(WINDIVERT_TCPHDR*)(rst_packet.ptr + (ip_header.HdrLength * 4));
                rst_tcp.Rst = 1;
                WinDivertSend(handle, rst_packet.ptr, packet_len, &addr, null);
            }
        }

        if ((config.fragment_tcp && is_http) || 
            (config.fragment_http && ntohs(tcp_header.DstPort) == 80) || 
            (config.fragment_https && ntohs(tcp_header.DstPort) == 443)) {
            fragmentTcpPacket(packet[0..packet_len], config.fragment_size, ip_header, tcp_header);
        }

        if (config.dnsv4_redirect && ntohs(tcp_header.DstPort) == 53) {
            auto dns_ip = parseIPv4(config.dnsv4_addr);
            ip_header.DstAddr = dns_ip;
        }

        WinDivertSend(handle, packet.ptr, packet_len, &addr, null);
    }
}

uint parseIPv4(string ip) {
    auto parts = ip.split(".");
    if (parts.length != 4) return 0;
    
    uint result = 0;
    foreach (i, part; parts) {
        result |= (to!uint(part) & 0xFF) << (8 * (3 - i));
    }
    return result;
}

void main(string[] args) {
    SetConsoleOutputCP(65001);
    writeln("Starting DeathDPI...");

    string configFile = "config.json";

    if (args.length > 1) {
        configFile = args[1];
    }

    if (!exists(configFile)) {
        writefln("Configuration file not found: %s", configFile);
        writeln("Creating default configuration file...");
        Config.createDefault(configFile);
    }

    auto config = cast(shared)new Config();
    *config = Config.fromJson(configFile);

    string filter = "tcp";
    if (config.blacklist) {
        filter ~= " and (";
        foreach (i, host; config.blacklist_hosts) {
            if (i > 0) filter ~= " or ";
            filter ~= format("tcp.DstPort == 80 and tcp.PayloadLength > 0 and tcp.Payload contains \"%s\"", host);
        }
        filter ~= ")";
    }

    auto handle = WinDivertOpen(filter.ptr, WINDIVERT_LAYER_NETWORK, 0, 0);
    
    if (handle == INVALID_HANDLE_VALUE) {
        stderr.writeln("Failed to open WinDivert. Make sure you run as administrator.");
        return;
    }

    auto tid = spawn(&processPacket, handle, config);

    writeln("DPI bypass active. The following features are enabled:");
    writefln("- HTTP/HTTPS packet fragmentation (fragment_size: %d)", config.fragment_size);
    writeln("- TCP packet manipulation");
    writefln("- TTL optimization (min: %d, max: %d)", config.auto_ttl_min, config.auto_ttl_max);
    if (config.dnsv4_redirect)
        writefln("- DNS redirection (%s)", config.dnsv4_addr);
    if (config.blacklist) {
        writeln("- Host-based filtering:");
        foreach (host; config.blacklist_hosts)
            writefln("  * %s", host);
    }
    writeln("\nPress Enter to exit...");
    
    readln();

    atomicStore(running, false);
    Thread.sleep(dur!"msecs"(100));
    WinDivertClose(handle);
} 
