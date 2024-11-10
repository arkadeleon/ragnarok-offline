//
//  PACKET_ZC_ACCEPT_ENTER.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/22.
//

import ROCore

/// See `clif_authok`
public struct PACKET_ZC_ACCEPT_ENTER: DecodablePacket {
    public static var packetType: Int16 {
        if PACKET_VERSION < 20080102 {
            0x73
        } else if PACKET_VERSION < 20141022 || PACKET_VERSION >= 20160330 {
            0x2eb
        } else {
            0xa18
        }
    }

    public var packetLength: Int16 {
        if PACKET_VERSION < 20080102 {
            2 + 4 + 3 + 1 + 1
        } else if PACKET_VERSION < 20141022 || PACKET_VERSION >= 20160330 {
            2 + 4 + 3 + 1 + 1 + 2
        } else {
            2 + 4 + 3 + 1 + 1 + 2 + 1
        }
    }

    public var startTime: UInt32
    public var positionAndDirection: [UInt8]
    public var xSize: UInt8
    public var ySize: UInt8
    public var font: UInt16
    public var sex: UInt8

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        startTime = try decoder.decode(UInt32.self)
        positionAndDirection = try decoder.decode([UInt8].self, count: 3)
        xSize = try decoder.decode(UInt8.self)
        ySize = try decoder.decode(UInt8.self)

        if PACKET_VERSION < 20080102 {
            font = 0
            sex = 0
        } else if PACKET_VERSION < 20141022 || PACKET_VERSION >= 20160330 {
            font = try decoder.decode(UInt16.self)
            sex = 0
        } else {
            font = try decoder.decode(UInt16.self)
            sex = try decoder.decode(UInt8.self)
        }
    }
}
