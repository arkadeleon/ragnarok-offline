//
//  PACKET_HC_NOTIFY_ZONESVR.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/4/8.
//

import BinaryIO

@available(*, deprecated, message: "Use HEADER_HC_NOTIFY_ZONESVR instead.")
public let _HEADER_HC_NOTIFY_ZONESVR: Int16 = PACKET_VERSION >= 20170315 ? 0xac5 : 0x71

/// See `chclif_send_map_data`
@available(*, deprecated, message: "Use PACKET_HC_NOTIFY_ZONESVR instead.")
public struct _PACKET_HC_NOTIFY_ZONESVR: DecodablePacket {
    public var packetType: Int16
    public var charID: UInt32
    public var mapName: String
    public var ip: UInt32
    public var port: UInt16

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
        charID = try decoder.decode(UInt32.self)
        mapName = try decoder.decode(String.self, lengthOfBytes: 16)
        ip = try decoder.decode(UInt32.self)
        port = try decoder.decode(UInt16.self)

        if PACKET_VERSION >= 20170315 {
            _ = try decoder.decode([UInt8].self, count: 128)
        }
    }
}
