//
//  PACKET_CH_DELETE_CHAR_CANCEL.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/4/8.
//

import BinaryIO

@available(*, deprecated, message: "Use HEADER_CH_DELETE_CHAR3_CANCEL instead.")
public let _HEADER_CH_DELETE_CHAR_CANCEL: Int16 = 0x82b

/// See `chclif_parse_char_delete2_cancel`
@available(*, deprecated, message: "Use PACKET_CH_DELETE_CHAR3_CANCEL instead.")
public struct _PACKET_CH_DELETE_CHAR_CANCEL: EncodablePacket {
    public var packetType: Int16 = 0
    public var charID: UInt32 = 0

    public init() {
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
        try encoder.encode(charID)
    }
}
