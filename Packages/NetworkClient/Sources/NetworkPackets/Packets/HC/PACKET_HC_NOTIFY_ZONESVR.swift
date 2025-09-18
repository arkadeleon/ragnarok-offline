//
//  PACKET_HC_NOTIFY_ZONESVR.swift
//  NetworkPackets
//
//  Created by Leon Li on 2024/4/8.
//

import BinaryIO

/// See `chclif_send_map_data`
public struct PACKET_HC_NOTIFY_ZONESVR: DecodablePacket, Sendable {
    public static var packetType: Int16 {
        if PACKET_VERSION >= 20170315 {
            0xac5
        } else {
            0x71
        }
    }

    public var packetLength: Int16 {
        if PACKET_VERSION >= 20170315 {
            2 + 4 + 16 + MapServerInfo.decodedLength + 128
        } else {
            2 + 4 + 16 + MapServerInfo.decodedLength
        }
    }

    public var charID: UInt32
    public var mapName: String
    public var mapServer: MapServerInfo

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        charID = try decoder.decode(UInt32.self)
        mapName = try decoder.decode(String.self, lengthOfBytes: 16)
        mapServer = try decoder.decode(MapServerInfo.self)

        if PACKET_VERSION >= 20170315 {
            _ = try decoder.decode([UInt8].self, count: 128)
        }
    }
}
