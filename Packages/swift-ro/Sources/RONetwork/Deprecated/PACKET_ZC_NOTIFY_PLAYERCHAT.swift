//
//  PACKET_ZC_NOTIFY_PLAYERCHAT.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/22.
//

import ROCore

public let HEADER_ZC_NOTIFY_PLAYERCHAT: Int16 = 0x8e

/// See `clif_displaymessage`
@available(*, deprecated, message: "Use `ROGenerated` instead.")
public struct _PACKET_ZC_NOTIFY_PLAYERCHAT: DecodablePacket {
    public static var packetType: Int16 {
        HEADER_ZC_NOTIFY_PLAYERCHAT
    }

    public var packetLength: Int16 {
        -1
    }

    public var message: String

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        let packetLength = try decoder.decode(Int16.self)

        message = try decoder.decode(String.self, lengthOfBytes: Int(packetLength - 4))
    }
}
