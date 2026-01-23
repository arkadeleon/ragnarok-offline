//
//  PACKET_ZC_NOTIFY_EXP.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2026/1/23.
//

import BinaryIO

public let HEADER_ZC_NOTIFY_EXP: Int16 = PACKET_VERSION >= 20170830 ? 0x0acc : 0x07f6

public struct PACKET_ZC_NOTIFY_EXP: DecodablePacket {
    public var packetType: Int16
    public var accountID: UInt32
    public var amount: Int64
    public var varID: UInt16
    public var expType: UInt16

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
        accountID = try decoder.decode(UInt32.self)
        if PACKET_VERSION >= 20170830 {
            amount = try decoder.decode(Int64.self)
        } else {
            amount = try Int64(decoder.decode(Int32.self))
        }
        varID = try decoder.decode(UInt16.self)
        expType = try decoder.decode(UInt16.self)
    }
}
