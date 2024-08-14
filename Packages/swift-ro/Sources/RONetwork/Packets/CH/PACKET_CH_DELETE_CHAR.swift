//
//  PACKET_CH_DELETE_CHAR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/6.
//

/// See `chclif_parse_delchar` and `chclif_parse_char_delete2_accept`
public struct PACKET_CH_DELETE_CHAR: EncodablePacket {
    public static var packetType: UInt16 {
        if PACKET_VERSION > 20100803 {
            0x829
        } else if PACKET_VERSION == 20040419 {
            0x1fb
        } else {
            0x68
        }
    }

    public var packetLength: UInt16 {
        if PACKET_VERSION > 20100803 {
            2 + 4 + 6
        } else if PACKET_VERSION == 20040419 {
            2 + 4 + 50
        } else {
            2 + 4 + 40
        }
    }

    public var gid: UInt32
    public var email: String
    public var birthdate: String

    public init() {
        gid = 0
        email = ""
        birthdate = ""
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
        try encoder.encode(gid)

        if PACKET_VERSION > 20100803 {
            try encoder.encode(birthdate, length: 6)
        } else if PACKET_VERSION == 20040419 {
            try encoder.encode(email, length: 50)
        } else {
            try encoder.encode(email, length: 40)
        }
    }
}
