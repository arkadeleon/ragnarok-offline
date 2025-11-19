//
//  PACKET_HC_ACCEPT_ENTER_NEO_UNION_HEADER.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/8/12.
//

import BinaryIO

public let HEADER_HC_ACCEPT_ENTER_NEO_UNION_HEADER: Int16 = 0x82d

/// See `chclif_mmo_send082d`
public struct PACKET_HC_ACCEPT_ENTER_NEO_UNION_HEADER: DecodablePacket {
    public var packetType: Int16
    public var totalSlot: UInt16
    public var normalSlot: UInt8
    public var premiumSlot: UInt8
    public var billingSlot: UInt8
    public var producibleSlot: UInt8
    public var validSlot: UInt8

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
        totalSlot = try decoder.decode(UInt16.self)
        normalSlot = try decoder.decode(UInt8.self)
        premiumSlot = try decoder.decode(UInt8.self)
        billingSlot = try decoder.decode(UInt8.self)
        producibleSlot = try decoder.decode(UInt8.self)
        validSlot = try decoder.decode(UInt8.self)
        _ = try decoder.decode([UInt8].self, count: 20)
    }
}
