//
//  PACKET_CA_LOGIN.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/5.
//

public struct PACKET_CA_LOGIN: EncodablePacket {
    public static var packetType: UInt16 {
        0x64
    }

    public var packetLength: UInt16 {
        2 + 4 + 24 + 24 + 1
    }

    public var version: UInt32 = 0
    public var username = ""
    public var password = ""
    public var clientType: UInt8 = 0

    public init() {
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
        try encoder.encode(version)
        try encoder.encode(username, length: 24)
        try encoder.encode(password, length: 24)
        try encoder.encode(clientType)
    }
}
