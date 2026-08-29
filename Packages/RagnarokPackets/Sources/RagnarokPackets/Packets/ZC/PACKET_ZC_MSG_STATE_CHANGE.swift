//
//  PACKET_ZC_MSG_STATE_CHANGE.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2026/8/29.
//

import BinaryIO

public struct PACKET_ZC_MSG_STATE_CHANGE: DecodablePacket {
    public var packetType: Int16
    public var index: Int16
    public var AID: UInt32
    public var state: UInt8

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
        index = try decoder.decode(Int16.self)
        AID = try decoder.decode(UInt32.self)
        state = try decoder.decode(UInt8.self)
    }
}
