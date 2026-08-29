//
//  PACKET_ZC_MSG_STATE_CHANGE3.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2026/8/29.
//

import BinaryIO

public struct PACKET_ZC_MSG_STATE_CHANGE3: DecodablePacket {
    public var packetType: Int16
    public var index: Int16
    public var AID: UInt32
    public var state: UInt8
    public var total: UInt32
    public var remain: UInt32
    public var val1: Int32
    public var val2: Int32
    public var val3: Int32

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
        index = try decoder.decode(Int16.self)
        AID = try decoder.decode(UInt32.self)
        state = try decoder.decode(UInt8.self)
        total = try decoder.decode(UInt32.self)
        remain = try decoder.decode(UInt32.self)
        val1 = try decoder.decode(Int32.self)
        val2 = try decoder.decode(Int32.self)
        val3 = try decoder.decode(Int32.self)
    }
}
