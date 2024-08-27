//
//  PACKET_CH_ENTER.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/6.
//

/// See `chclif_parse_reqtoconnect`
public struct PACKET_CH_ENTER: EncodablePacket {
    public var packetType: Int16 {
        0x65
    }

    public var packetLength: Int16 {
        2 + 4 + 4 + 4 + 2 + 1
    }

    public var accountID: UInt32
    public var loginID1: UInt32
    public var loginID2: UInt32
    public var clientType: UInt16
    public var sex: UInt8

    public init() {
        accountID = 0
        loginID1 = 0
        loginID2 = 0
        clientType = 0
        sex = 0
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
        try encoder.encode(accountID)
        try encoder.encode(loginID1)
        try encoder.encode(loginID2)
        try encoder.encode(clientType)
        try encoder.encode(sex)
    }
}
