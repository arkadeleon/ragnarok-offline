//
//  PacketManager.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/8.
//

public class PacketManager {
    public static let shared = PacketManager()

    public let decodablePackets: [any DecodablePacket.Type] = [
        /// Login Server -> Client
        PACKET_AC_ACCEPT_LOGIN.self,                // 0x69, 0xac4
        PACKET_AC_REFUSE_LOGIN.self,                // 0x6a, 0x83e

        /// Char Server -> Client
        PACKET_HC_ACCEPT_ENTER_NEO_UNION.self,      // 0x6b
        PACKET_HC_REFUSE_ENTER.self,                // 0x6c
        PACKET_HC_ACCEPT_MAKECHAR_NEO_UNION.self,             // 0b6d
        PACKET_HC_REFUSE_MAKECHAR.self,             // 0x6e
        PACKET_HC_ACCEPT_DELETECHAR.self,           // 0x6f
        PACKET_HC_REFUSE_DELETECHAR.self,           // 0x70
        PACKET_HC_NOTIFY_ZONESVR.self,              // 0x71, 0xac5
        PACKET_HC_DELETE_CHAR.self,                 // 0x82a
        PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME.self,   // 0x840

        /// Map Server -> Client

        /// All Servers -> Client
        PACKET_SC_NOTIFY_BAN.self,                  // 0x81
    ]

    public let encodablePackets: [any EncodablePacket.Type] = [
        /// Client -> Login Server
        PACKET_CA_LOGIN.self,                       // 0x64
        PACKET_CA_CONNECT_INFO_CHANGED.self,        // 0x200
        PACKET_CA_EXE_HASHCHECK.self,               // 0x204

        /// Client -> Char Server
        PACKET_CH_ENTER.self,                       // 0x65
        PACKET_CH_SELECT_CHAR.self,                 // 0x66
        PACKET_CH_MAKE_CHAR.self,                   // 0x67, 0x970, 0xa39
        PACKET_CH_DELETE_CHAR.self,                 // 0x68, 0x1fb
        PACKET_CH_DELETE_CHAR_RESERVED.self,        // 0x827
        PACKET_CH_DELETE_CHAR_CANCEL.self,          // 0x82b
        PACKET_CH_SELECT_ACCESSIBLE_MAPNAME.self,   // 0x841

        /// Client -> Map Server
        PACKET_CZ_PING.self,                        // 0x187

        /// Client -> All Servers
    ]
}
