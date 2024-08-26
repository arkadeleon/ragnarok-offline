//
//  PACKET_CH_SELECT_CHAR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/6.
//

/// See `chclif_parse_charselect`
public struct PACKET_CH_SELECT_CHAR: EncodablePacket {
    public var packetType: Int16 {
        0x66
    }

    public var packetLength: Int16 {
        2 + 1
    }

    public var charNum: UInt8

    public init() {
        charNum = 0
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
        try encoder.encode(charNum)
    }
}
