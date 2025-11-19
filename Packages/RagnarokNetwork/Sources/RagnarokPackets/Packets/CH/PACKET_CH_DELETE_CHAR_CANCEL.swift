//
//  PACKET_CH_DELETE_CHAR_CANCEL.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/4/8.
//

import BinaryIO

public let HEADER_CH_DELETE_CHAR_CANCEL: Int16 = 0x82b

/// See `chclif_parse_char_delete2_cancel`
public struct PACKET_CH_DELETE_CHAR_CANCEL: EncodablePacket {
    public var packetType: Int16 = 0
    public var charID: UInt32 = 0

    public init() {
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
        try encoder.encode(charID)
    }
}
