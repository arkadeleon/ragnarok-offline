//
//  PACKET_ZC_PARTY_CONFIG.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/29.
//

import ROCore

/// See `clif_partyinvitationstate`
public struct PACKET_ZC_PARTY_CONFIG: DecodablePacket {
    public static var packetType: Int16 {
        0x2c9
    }

    public var packetLength: Int16 {
        3
    }

    /// 0 = allow party invites
    /// 1 = auto-deny party invites
    public var flag: UInt8

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        flag = try decoder.decode(UInt8.self)
    }
}
