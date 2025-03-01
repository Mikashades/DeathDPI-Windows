module windivert;

import core.sys.windows.windows;
import core.stdc.config;

extern (Windows):

struct WINDIVERT_ADDRESS {
    UINT64 Timestamp;
    UINT32 Layer;
    UINT32 Event;
    UINT32 Flags;
    union {
        UINT32 Priority;
        UINT32 ProcessId;
    }
    UINT32 Reserved1;
    UINT32 Reserved2;
    UINT32 Reserved3;
}

struct WINDIVERT_IPHDR {
    UINT8  HdrLength:4;
    UINT8  Version:4;
    UINT8  TOS;
    UINT16 Length;
    UINT16 Id;
    UINT16 FragOff0;
    UINT8  TTL;
    UINT8  Protocol;
    UINT16 Checksum;
    UINT32 SrcAddr;
    UINT32 DstAddr;
}

struct WINDIVERT_TCPHDR {
    UINT16 SrcPort;
    UINT16 DstPort;
    UINT32 SeqNum;
    UINT32 AckNum;
    UINT16 Reserved1:4;
    UINT16 HdrLength:4;
    UINT16 Fin:1;
    UINT16 Syn:1;
    UINT16 Rst:1;
    UINT16 Psh:1;
    UINT16 Ack:1;
    UINT16 Urg:1;
    UINT16 Reserved2:2;
    UINT16 Window;
    UINT16 Checksum;
    UINT16 UrgPtr;
}

enum WINDIVERT_LAYER_NETWORK = 0;
enum WINDIVERT_FLAG_SNIFF = 1;

HANDLE WinDivertOpen(const(char)* filter, UINT layer, INT16 priority, UINT64 flags);
BOOL WinDivertRecv(HANDLE handle, void* pPacket, UINT packetLen, WINDIVERT_ADDRESS* pAddr, UINT* readLen);
BOOL WinDivertSend(HANDLE handle, void* pPacket, UINT packetLen, WINDIVERT_ADDRESS* pAddr, UINT* writeLen);
BOOL WinDivertClose(HANDLE handle); 