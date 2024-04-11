//
//  PACKET_CH_DELETE_CHAR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/6.
//

public struct PACKET_CH_DELETE_CHAR: EncodablePacket {
    public static var packetType: UInt16 {
        if PACKET_VERSION > 20100803 {
            0x1fb
        } else {
            0x68
        }
    }

    public var packetLength: UInt16 {
        if PACKET_VERSION > 20100803 {
            2 + 4 + 50
        } else {
            2 + 4 + 40
        }
    }

    public var gid: UInt32 = 0
    public var key = ""

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
        try encoder.encode(gid)

        if PACKET_VERSION > 20100803 {
            try encoder.encode(key, length: 50)
        } else {
            try encoder.encode(key, length: 40)
        }
    }
}
