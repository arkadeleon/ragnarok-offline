//
//  PACKET_HC_NOTIFY_ZONESVR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/8.
//

public struct PACKET_HC_NOTIFY_ZONESVR: DecodablePacket {
    public static var packetType: Int16 {
        if PACKET_VERSION >= 20170315 {
            0xac5
        } else {
            0x71
        }
    }

    public var packetLength: Int16 {
        if PACKET_VERSION >= 20170315 {
            2 + 4 + 16 + 4 + 2 + 128
        } else {
            2 + 4 + 16 + 4 + 2
        }
    }

    public var gid: UInt32
    public var mapName: String
    public var serverInfo: ServerInfo

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        gid = try decoder.decode(UInt32.self)
        mapName = try decoder.decode(String.self, length: 16)
        serverInfo = try decoder.decode(ServerInfo.self)

        if PACKET_VERSION >= 20170315 {
            _ = try decoder.decode([UInt8].self, length: 128)
        }
    }
}

extension PACKET_HC_NOTIFY_ZONESVR {
    public struct ServerInfo: BinaryDecodable {
        public var ip: UInt32
        public var port: UInt16

        public init(from decoder: BinaryDecoder) throws {
            ip = try decoder.decode(UInt32.self)
            port = try decoder.decode(UInt16.self)
        }
    }
}
