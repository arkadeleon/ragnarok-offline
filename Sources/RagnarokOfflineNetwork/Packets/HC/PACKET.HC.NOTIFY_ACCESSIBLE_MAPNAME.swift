//
//  PACKET.HC.NOTIFY_ACCESSIBLE_MAPNAME.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/9.
//

extension PACKET.HC {
    public struct NOTIFY_ACCESSIBLE_MAPNAME: PacketProtocol {
        public enum PacketType: UInt16, PacketTypeProtocol {
            case x0840 = 0x0840
        }

        public let packetType: PacketType
        public var maps: [MapInfo] = []

        public var packetName: String {
            "PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME"
        }

        public var packetLength: UInt16 {
            2 + 2 + (4 + 16) * UInt16(maps.count)
        }

        public init(packetVersion: PacketVersion) {
            packetType = .x0840
        }

        public init(from decoder: BinaryDecoder) throws {
            packetType = try decoder.decode(PacketType.self)

            let packetLength = try decoder.decode(UInt16.self)

            let mapCount = (packetLength - 4) / (4 + 16)
            for _ in 0..<mapCount {
                let map = try MapInfo(from: decoder)
                maps.append(map)
            }
        }

        public func encode(to encoder: BinaryEncoder) throws {
            try encoder.encode(packetType)
            try encoder.encode(packetLength)
            for map in maps {
                try encoder.encode(map)
            }
        }
    }
}

extension PACKET.HC.NOTIFY_ACCESSIBLE_MAPNAME {
    public struct MapInfo: BinaryEncodable, BinaryDecodable {
        public var status: UInt32 = 0
        public var mapName = ""

        public init() {
        }

        public init(from decoder: BinaryDecoder) throws {
            status = try decoder.decode(UInt32.self)
            mapName = try decoder.decode(String.self, length: 16)
        }

        public func encode(to encoder: BinaryEncoder) throws {
            try encoder.encode(status)
            try encoder.encode(mapName, length: 16)
        }
    }
}
