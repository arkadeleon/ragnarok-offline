//
//  PACKET_CH_ENTER.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2021/7/6.
//

import BinaryIO

public let HEADER_CH_ENTER: Int16 = 0x65

/// See `chclif_parse_reqtoconnect`
public struct PACKET_CH_ENTER: EncodablePacket {
    public var packetType: Int16 = 0
    public var accountID: UInt32 = 0
    public var loginID1: UInt32 = 0
    public var loginID2: UInt32 = 0
    public var clientType: UInt16 = 0
    public var sex: UInt8 = 0

    public init() {
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
