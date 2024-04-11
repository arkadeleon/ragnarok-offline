//
//  PACKET.HC.NOTIFY_ZONESVR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/8.
//

extension PACKET.HC {
    public struct NOTIFY_ZONESVR: PacketProtocol {
        public enum PacketType: UInt16, PacketTypeProtocol {
            case x0071 = 0x0071
            case x0ac5 = 0x0ac5
        }

        public let packetType: PacketType
        public var gid: UInt32 = 0
        public var mapName = ""
        public var serverInfo = ServerInfo()

        public var packetName: String {
            "PACKET_HC_NOTIFY_ZONESVR"
        }

        public var packetLength: UInt16 {
            switch packetType {
            case .x0071:
                2 + 4 + 16 + 4 + 2
            case .x0ac5:
                2 + 4 + 16 + 4 + 2 + 128
            }
        }

        public init(packetVersion: PacketVersion) {
            if packetVersion.number < 20170315 {
                packetType = .x0071
            } else {
                packetType = .x0ac5
            }
        }

        public init(from decoder: BinaryDecoder) throws {
            packetType = try decoder.decode(PacketType.self)
            gid = try decoder.decode(UInt32.self)
            mapName = try decoder.decode(String.self, length: 16)
            serverInfo = try decoder.decode(ServerInfo.self)

            if packetType == .x0ac5 {
                _ = try decoder.decode([UInt8].self, length: 128)
            }
        }

        public func encode(to encoder: BinaryEncoder) throws {
            try encoder.encode(packetType)
            try encoder.encode(gid)
            try encoder.encode(mapName, length: 16)
            try encoder.encode(serverInfo)

            if packetType == .x0ac5 {
                try encoder.encode([UInt8](repeating: 0, count: 128))
            }
        }
    }
}

extension PACKET.HC.NOTIFY_ZONESVR {
    public struct ServerInfo: BinaryDecodable, BinaryEncodable {
        public var ip: UInt32 = 0
        public var port: UInt16 = 0

        public init() {
        }

        public init(from decoder: BinaryDecoder) throws {
            ip = try decoder.decode(UInt32.self)
            port = try decoder.decode(UInt16.self)
        }

        public func encode(to encoder: BinaryEncoder) throws {
            try encoder.encode(ip)
            try encoder.encode(port)
        }
    }
}
