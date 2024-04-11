//
//  PACKET.HC.NOTIFY_ACCESSIBLE_MAPNAME.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/9.
//

extension PACKET.HC {
    public struct NOTIFY_ACCESSIBLE_MAPNAME: DecodablePacket {
        public static var packetType: UInt16 {
            0x840
        }

        public var maps: [MapInfo]

        public var packetName: String {
            "PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME"
        }

        public var packetLength: UInt16 {
            2 + 2 + (4 + 16) * UInt16(maps.count)
        }

        public init(from decoder: BinaryDecoder) throws {
            try decoder.decodePacketType(Self.self)

            let packetLength = try decoder.decode(UInt16.self)

            let mapCount = (packetLength - 4) / (4 + 16)

            maps = []
            for _ in 0..<mapCount {
                let map = try MapInfo(from: decoder)
                maps.append(map)
            }
        }
    }
}

extension PACKET.HC.NOTIFY_ACCESSIBLE_MAPNAME {
    public struct MapInfo: BinaryDecodable {
        public var status: UInt32
        public var mapName: String

        public init(from decoder: BinaryDecoder) throws {
            status = try decoder.decode(UInt32.self)
            mapName = try decoder.decode(String.self, length: 16)
        }
    }
}
