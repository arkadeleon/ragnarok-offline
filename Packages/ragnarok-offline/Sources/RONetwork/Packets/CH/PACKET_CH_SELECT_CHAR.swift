//
//  PACKET_CH_SELECT_CHAR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/6.
//

public struct PACKET_CH_SELECT_CHAR: EncodablePacket {
    public static var packetType: UInt16 {
        0x66
    }

    public var packetLength: UInt16 {
        2 + 1
    }

    public var charNum: UInt8 = 0

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
        try encoder.encode(charNum)
    }
}
