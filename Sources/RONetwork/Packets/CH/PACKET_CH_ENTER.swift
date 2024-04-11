//
//  PACKET_CH_ENTER.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/6.
//

public struct PACKET_CH_ENTER: EncodablePacket {
    public static var packetType: UInt16 {
        0x65
    }

    public var packetLength: UInt16 {
        2 + 4 + 4 + 4 + 2 + 1
    }

    public var aid: UInt32 = 0
    public var authCode: UInt32 = 0
    public var userLevel: UInt32 = 0
    public var clientType: UInt16 = 0
    public var sex: UInt8 = 0

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
        try encoder.encode(aid)
        try encoder.encode(authCode)
        try encoder.encode(userLevel)
        try encoder.encode(clientType)
        try encoder.encode(sex)
    }
}
