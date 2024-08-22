//
//  PACKET_ZC_NOTIFY_PLAYERCHAT.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/22.
//

public struct PACKET_ZC_NOTIFY_PLAYERCHAT: DecodablePacket {
    public static var packetType: UInt16 {
        0x8e
    }

    public var packetLength: UInt16 {
        4 + UInt16(message.count)
    }

    public var message: [UInt8]

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        let packetLength = try decoder.decode(UInt16.self)

        message = try decoder.decode([UInt8].self, length: Int(packetLength - 4))
    }
}
