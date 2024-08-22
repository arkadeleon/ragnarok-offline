//
//  PACKET_AC_REFUSE_LOGIN.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/6.
//

public struct PACKET_AC_REFUSE_LOGIN: DecodablePacket {
    public static var packetType: Int16 {
        if PACKET_VERSION >= 20120000 {
            0x83e
        } else {
            0x6a
        }
    }

    public var packetLength: Int16 {
        if PACKET_VERSION >= 20120000 {
            2 + 4 + 20
        } else {
            2 + 1 + 20
        }
    }

    public var errorCode: UInt32
    public var blockDate: String

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        if PACKET_VERSION >= 20120000 {
            errorCode = try decoder.decode(UInt32.self)
        } else {
            errorCode = try UInt32(decoder.decode(UInt8.self))
        }

        blockDate = try decoder.decode(String.self, length: 20)
    }
}
