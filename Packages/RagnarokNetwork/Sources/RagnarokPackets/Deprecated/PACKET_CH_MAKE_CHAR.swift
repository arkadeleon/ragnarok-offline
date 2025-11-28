//
//  PACKET_CH_MAKE_CHAR.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2021/7/6.
//

import BinaryIO

@available(*, deprecated, message: "Use HEADER_CH_MAKE_CHAR instead.")
public let _HEADER_CH_MAKE_CHAR: Int16 = {
    if PACKET_VERSION >= 20151001 {
        0xa39
    } else if PACKET_VERSION >= 20120307 {
        0x970
    } else {
        0x67
    }
}()

/// See `chclif_parse_createnewchar`
@available(*, deprecated, message: "Use PACKET_CH_MAKE_CHAR instead.")
public struct _PACKET_CH_MAKE_CHAR: EncodablePacket {
    public var packetType: Int16 = 0
    public var name: String = ""
    public var str: UInt8 = 0
    public var agi: UInt8 = 0
    public var vit: UInt8 = 0
    public var int: UInt8 = 0
    public var dex: UInt8 = 0
    public var luk: UInt8 = 0
    public var slot: UInt8 = 0
    public var hairColor: UInt16 = 0
    public var hairStyle: UInt16 = 0
    public var job: UInt16 = 0
    public var sex: UInt8 = 0

    public init() {
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
