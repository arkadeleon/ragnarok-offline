//
//  PACKET_CH_DELETE_CHAR_RESERVED.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/4/8.
//

import BinaryIO

@available(*, deprecated, message: "Use HEADER_CH_DELETE_CHAR3_RESERVED instead.")
public let _HEADER_CH_DELETE_CHAR_RESERVED: Int16 = 0x827

/// See `chclif_parse_char_delete2_req`
@available(*, deprecated, message: "Use PACKET_CH_DELETE_CHAR3_RESERVED instead.")
public struct _PACKET_CH_DELETE_CHAR_RESERVED: EncodablePacket {
    public var packetType: Int16 = 0
    public var charID: UInt32 = 0

    public init() {
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
        try encoder.encode(charID)
    }
}
