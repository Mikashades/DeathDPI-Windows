module config;

import std.json;
import std.file;
import std.stdio;
import std.conv;

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

    static Config fromJson(string filename) {
        Config config;

        try {
            string jsonText = readText(filename);
            JSONValue json = parseJSON(jsonText);

            void loadBool(string key) {
                if (key in json) mixin("config." ~ key ~ " = json[key].boolean;");
            }

            void loadInt(string key) {
                if (key in json) mixin("config." ~ key ~ " = cast(typeof(config." ~ key ~ "))json[key].integer;");
            }

            void loadString(string key) {
                if (key in json) mixin("config." ~ key ~ " = json[key].str;");
            }

            loadBool("fragment_http");
            loadBool("fragment_https");
            loadBool("modify_ttl");
            loadInt("min_ttl");
            loadBool("random_http_header");
            loadBool("fragment_tcp");
            loadInt("fragment_size");
            loadBool("reverse_tcp");
            loadBool("wrong_seq");
            loadBool("wrong_chksum");
            loadBool("wrong_http");
            loadBool("split_pos");
            loadInt("split_pos_value");
            loadBool("fake_rst");
            loadBool("auto_ttl");
            loadInt("auto_ttl_min");
            loadInt("auto_ttl_max");
            loadBool("blacklist");
            loadBool("dnsv4_redirect");
            loadString("dnsv4_addr");
            loadBool("ipv6_support");
            loadBool("https_tampering");
            loadBool("packet_fragmentation");
            loadInt("max_packet_size");
            loadBool("tcp_tampering");
            loadBool("udp_tampering");
            loadBool("icmp_tampering");
            loadBool("logging");
            loadString("log_file");
            loadInt("log_level");
            loadBool("statistics");
            loadInt("stats_interval");
            loadBool("auto_update");
            loadString("update_url");
            loadBool("gui_support");

            void loadStringArray(string key) {
                if (key in json && json[key].type == JSONType.array) {
                    mixin("config." ~ key ~ ".length = 0;");
                    foreach (item; json[key].array) {
                        mixin("config." ~ key ~ " ~= item.str;");
                    }
                }
            }

            loadStringArray("blacklist_hosts");
            loadStringArray("whitelist_hosts");
        }
        catch (Exception e) {
            stderr.writefln("Error loading configuration file: %s", e.msg);
            stderr.writeln("Using default configuration.");
        }

        return config;
    }

    void toJson(string filename) {
        JSONValue[string] jsonObj;

        void saveBool(string key) {
            mixin("jsonObj[key] = JSONValue(this." ~ key ~ ");");
        }

        void saveInt(string key) {
            mixin("jsonObj[key] = JSONValue(cast(long)this." ~ key ~ ");");
        }

        void saveString(string key) {
            mixin("jsonObj[key] = JSONValue(this." ~ key ~ ");");
        }

        void saveStringArray(string key) {
            mixin("jsonObj[key] = JSONValue(this." ~ key ~ ");");
        }

        saveBool("fragment_http");
        saveBool("fragment_https");
        saveBool("modify_ttl");
        saveInt("min_ttl");
        saveBool("random_http_header");
        saveBool("fragment_tcp");
        saveInt("fragment_size");
        saveBool("reverse_tcp");
        saveBool("wrong_seq");
        saveBool("wrong_chksum");
        saveBool("wrong_http");
        saveBool("split_pos");
        saveInt("split_pos_value");
        saveBool("fake_rst");
        saveBool("auto_ttl");
        saveInt("auto_ttl_min");
        saveInt("auto_ttl_max");
        saveBool("blacklist");
        saveBool("dnsv4_redirect");
        saveString("dnsv4_addr");
        saveBool("ipv6_support");
        saveBool("https_tampering");
        saveBool("packet_fragmentation");
        saveInt("max_packet_size");
        saveBool("tcp_tampering");
        saveBool("udp_tampering");
        saveBool("icmp_tampering");
        saveBool("logging");
        saveString("log_file");
        saveInt("log_level");
        saveBool("statistics");
        saveInt("stats_interval");
        saveBool("auto_update");
        saveString("update_url");
        saveBool("gui_support");
        saveStringArray("blacklist_hosts");
        saveStringArray("whitelist_hosts");

        try {
            std.file.write(filename, JSONValue(jsonObj).toPrettyString());
        }
        catch (Exception e) {
            stderr.writefln("Error saving configuration file: %s", e.msg);
        }
    }

    static void createDefault(string filename) {
        Config config;
        config.blacklist_hosts = [
            "*.facebook.com",
            "*.google.com",
            "*.youtube.com",
            "*.twitter.com"
        ];
        config.whitelist_hosts = [
            "*.github.com",
            "*.githubusercontent.com"
        ];
        config.toJson(filename);
    }
} 