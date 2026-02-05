//
//  PACKET_ZC_NOTIFY_EFFECT2.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2026/2/5.
//

import BinaryIO

public let HEADER_ZC_NOTIFY_EFFECT2: Int16 = 0x1f3

public struct PACKET_ZC_NOTIFY_EFFECT2: DecodablePacket {
    public var packetType: Int16
    public var AID: UInt32
    public var effectID: UInt32

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
        AID = try decoder.decode(UInt32.self)
        effectID = try decoder.decode(UInt32.self)
    }
}
