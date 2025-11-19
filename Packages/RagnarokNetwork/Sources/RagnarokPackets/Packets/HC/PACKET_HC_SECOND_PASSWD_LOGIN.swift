//
//  PACKET_HC_SECOND_PASSWD_LOGIN.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/8/12.
//

import BinaryIO

public let HEADER_HC_SECOND_PASSWD_LOGIN: Int16 = 0x8b9

/// See `chclif_pincode_sendstate`
public struct PACKET_HC_SECOND_PASSWD_LOGIN: DecodablePacket {
    public var packetType: Int16
    public var pinCodeSeed: UInt32
    public var accountID: UInt32
    public var state: UInt16

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
        pinCodeSeed = try decoder.decode(UInt32.self)
        accountID = try decoder.decode(UInt32.self)
        state = try decoder.decode(UInt16.self)
    }
}
