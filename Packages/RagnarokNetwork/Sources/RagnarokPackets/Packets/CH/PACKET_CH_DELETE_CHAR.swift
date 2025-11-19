//
//  PACKET_CH_DELETE_CHAR.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2021/7/6.
//

import BinaryIO

public let HEADER_CH_DELETE_CHAR: Int16 = {
    if PACKET_VERSION > 20100803 {
        0x829
    } else if PACKET_VERSION == 20040419 {
        0x1fb
    } else {
        0x68
    }
}()

/// See `chclif_parse_delchar` and `chclif_parse_char_delete2_accept`
public struct PACKET_CH_DELETE_CHAR: EncodablePacket {
    public var packetType: Int16 = 0
    public var charID: UInt32 = 0
    public var email: String = ""
    public var birthdate: String = ""

    public init() {
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
        try encoder.encode(charID)

        if PACKET_VERSION > 20100803 {
            try encoder.encode(birthdate, lengthOfBytes: 6)
        } else if PACKET_VERSION == 20040419 {
            try encoder.encode(email, lengthOfBytes: 50)
        } else {
            try encoder.encode(email, lengthOfBytes: 40)
        }
    }
}
