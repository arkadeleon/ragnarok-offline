//
//  PACKET_CH_SELECT_CHAR.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2021/7/6.
//

import BinaryIO

@available(*, deprecated, message: "Use HEADER_CH_SELECT_CHAR instead.")
public let _HEADER_CH_SELECT_CHAR: Int16 = 0x66

/// See `chclif_parse_charselect`
@available(*, deprecated, message: "Use PACKET_CH_SELECT_CHAR instead.")
public struct _PACKET_CH_SELECT_CHAR: EncodablePacket {
    public var packetType: Int16 = 0
    public var slot: UInt8 = 0

    public init() {
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
        try encoder.encode(slot)
    }
}
