//
//  PACKET_CH_ENTER.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/6.
//

public struct PACKET_CH_ENTER: EncodablePacket {
    public static var packetType: Int16 {
        0x65
    }

    public var packetLength: Int16 {
        2 + 4 + 4 + 4 + 2 + 1
    }

    public var aid: UInt32
    public var authCode: UInt32
    public var userLevel: UInt32
    public var clientType: UInt16
    public var sex: UInt8

    public init() {
        aid = 0
        authCode = 0
        userLevel = 0
        clientType = 0
        sex = 0
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
        try encoder.encode(aid)
        try encoder.encode(authCode)
        try encoder.encode(userLevel)
        try encoder.encode(clientType)
        try encoder.encode(sex)
    }
}
