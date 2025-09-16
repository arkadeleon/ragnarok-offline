//
//  PACKET_CH_MAKE_CHAR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/6.
//

import BinaryIO

/// See `chclif_parse_createnewchar`
public struct PACKET_CH_MAKE_CHAR: EncodablePacket {
    public var packetType: Int16 {
        if PACKET_VERSION >= 20151001 {
            0xa39
        } else if PACKET_VERSION >= 20120307 {
            0x970
        } else {
            0x67
        }
    }

    public var packetLength: Int16 {
        if PACKET_VERSION >= 20151001 {
            2 + 24 + 1 + 2 + 2 + 2 + 1 + 1 + 1
        } else if PACKET_VERSION >= 20120307 {
            2 + 24 + 1 + 2 + 2
        } else {
            2 + 24 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 2 + 2
        }
    }

    public var name: String
    public var str: UInt8
    public var agi: UInt8
    public var vit: UInt8
    public var int: UInt8
    public var dex: UInt8
    public var luk: UInt8
    public var slot: UInt8
    public var hairColor: UInt16
    public var hairStyle: UInt16
    public var job: UInt16
    public var sex: UInt8

    public init() {
        name = ""
        str = 0
        agi = 0
        vit = 0
        int = 0
        dex = 0
        luk = 0
        slot = 0
        hairColor = 0
        hairStyle = 0
        job = 0
        sex = 0
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)

        try encoder.encode(name, lengthOfBytes: 24)

        if PACKET_VERSION < 20120307 {
            try encoder.encode(str)
            try encoder.encode(agi)
            try encoder.encode(vit)
            try encoder.encode(int)
            try encoder.encode(dex)
            try encoder.encode(luk)
        }

        try encoder.encode(slot)
        try encoder.encode(hairColor)
        try encoder.encode(hairStyle)

        if PACKET_VERSION >= 20151001 {
            try encoder.encode(job)
            try encoder.encode(0 as UInt8)
            try encoder.encode(0 as UInt8)
            try encoder.encode(sex)
        }
    }
}
