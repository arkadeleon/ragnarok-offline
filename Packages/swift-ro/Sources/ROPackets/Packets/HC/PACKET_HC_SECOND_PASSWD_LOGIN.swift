//
//  PACKET_HC_SECOND_PASSWD_LOGIN.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/12.
//

import BinaryIO

/// See `chclif_pincode_sendstate`
public struct PACKET_HC_SECOND_PASSWD_LOGIN: DecodablePacket, Sendable {
    public static var packetType: Int16 {
        0x8b9
    }

    public var packetLength: Int16 {
        2 + 4 + 4 + 2
    }

    public var pinCodeSeed: UInt32
    public var accountID: UInt32
    public var state: UInt16

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        pinCodeSeed = try decoder.decode(UInt32.self)
        accountID = try decoder.decode(UInt32.self)
        state = try decoder.decode(UInt16.self)
    }
}
