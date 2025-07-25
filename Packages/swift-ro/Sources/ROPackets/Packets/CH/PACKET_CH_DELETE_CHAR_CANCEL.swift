//
//  PACKET_CH_DELETE_CHAR_CANCEL.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/8.
//

import BinaryIO

/// See `chclif_parse_char_delete2_cancel`
public struct PACKET_CH_DELETE_CHAR_CANCEL: EncodablePacket {
    public var packetType: Int16 {
        0x82b
    }

    public var packetLength: Int16 {
        2 + 4
    }

    public var charID: UInt32

    public init() {
        charID = 0
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
        try encoder.encode(charID)
    }
}
