//
//  PACKET_HC_ACCEPT_ENTER_NEO_UNION.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/7/7.
//

/// See `chclif_mmo_send006b`
public struct PACKET_HC_ACCEPT_ENTER_NEO_UNION: DecodablePacket {
    public static var packetType: Int16 {
        0x6b
    }

    public var packetLength: Int16 {
        var packetLength: Int16 = 2 + 2
        if PACKET_VERSION >= 20100413 {
            packetLength += 1 + 1 + 1
        }
        packetLength += 20
        packetLength += CharInfo.size * Int16(chars.count)
        return packetLength
    }

    public var maxSlots: UInt8
    public var availableSlots: UInt8
    public var premiumSlots: UInt8
    public var chars: [CharInfo]

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        let packetLength = try decoder.decode(Int16.self)

        let charCount: Int16
        if PACKET_VERSION >= 20100413 {
            charCount = (packetLength - 27) / CharInfo.size
        } else {
            charCount = (packetLength - 24) / CharInfo.size
        }

        if PACKET_VERSION >= 20100413 {
            maxSlots = try decoder.decode(UInt8.self)
            availableSlots = try decoder.decode(UInt8.self)
            premiumSlots = try decoder.decode(UInt8.self)
        } else {
            maxSlots = 0
            availableSlots = 0
            premiumSlots = 0
        }

        _ = try decoder.decode(String.self, length: 20)

        chars = []
        for _ in 0..<charCount {
            let charInfo = try decoder.decode(CharInfo.self)
            chars.append(charInfo)
        }
    }
}
