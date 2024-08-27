//
//  PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/9.
//

/// See `chclif_accessible_maps`
public struct PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME: DecodablePacket {
    public static var packetType: Int16 {
        0x840
    }

    public var packetLength: Int16 {
        2 + 2 + MapInfo.size * Int16(maps.count)
    }

    public var maps: [MapInfo]

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        let packetLength = try decoder.decode(Int16.self)

        let mapCount = (packetLength - 2 - 2) / MapInfo.size

        maps = []
        for _ in 0..<mapCount {
            let mapInfo = try MapInfo(from: decoder)
            maps.append(mapInfo)
        }
    }
}

extension PACKET_HC_NOTIFY_ACCESSIBLE_MAPNAME {
    public struct MapInfo: BinaryDecodable {
        public static var size: Int16 {
            4 + 16
        }

        public var status: UInt32
        public var mapName: String

        public init(from decoder: BinaryDecoder) throws {
            status = try decoder.decode(UInt32.self)
            mapName = try decoder.decode(String.self, length: 16)
        }
    }
}
