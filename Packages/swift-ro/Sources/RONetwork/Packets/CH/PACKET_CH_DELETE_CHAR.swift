//
//  PACKET_CH_DELETE_CHAR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/6.
//

import ROCore

/// See `chclif_parse_delchar` and `chclif_parse_char_delete2_accept`
public struct PACKET_CH_DELETE_CHAR: EncodablePacket {
    public var packetType: Int16 {
        if PACKET_VERSION > 20100803 {
            0x829
        } else if PACKET_VERSION == 20040419 {
            0x1fb
        } else {
            0x68
        }
    }

    public var packetLength: Int16 {
        if PACKET_VERSION > 20100803 {
            2 + 4 + 6
        } else if PACKET_VERSION == 20040419 {
            2 + 4 + 50
        } else {
            2 + 4 + 40
        }
    }

    public var charID: UInt32
    public var email: String
    public var birthdate: String

    public init() {
        charID = 0
        email = ""
        birthdate = ""
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
        try encoder.encode(charID)

        if PACKET_VERSION > 20100803 {
            try encoder.encode(birthdate, length: 6)
        } else if PACKET_VERSION == 20040419 {
            try encoder.encode(email, length: 50)
        } else {
            try encoder.encode(email, length: 40)
        }
    }
}
