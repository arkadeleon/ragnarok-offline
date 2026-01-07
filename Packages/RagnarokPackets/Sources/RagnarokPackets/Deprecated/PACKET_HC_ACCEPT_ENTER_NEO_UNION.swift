//
//  PACKET_HC_ACCEPT_ENTER_NEO_UNION.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2021/7/7.
//

import BinaryIO

@available(*, deprecated, message: "Use HEADER_HC_ACCEPT_ENTER instead.")
public let _HEADER_HC_ACCEPT_ENTER_NEO_UNION: Int16 = 0x6b

/// See `chclif_mmo_send006b`
@available(*, deprecated, message: "Use PACKET_HC_ACCEPT_ENTER instead.")
public struct _PACKET_HC_ACCEPT_ENTER_NEO_UNION: DecodablePacket {
    public var packetType: Int16
    public var packetLength: Int16
    public var maxSlots: UInt8
    public var availableSlots: UInt8
    public var premiumSlots: UInt8
    public var chars: [CHARACTER_INFO]

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
        packetLength = try decoder.decode(Int16.self)

        let charCount: Int
        if PACKET_VERSION >= 20100413 {
            charCount = Int(packetLength - 27) / CHARACTER_INFO.size
        } else {
            charCount = Int(packetLength - 24) / CHARACTER_INFO.size
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

        _ = try decoder.decode(String.self, lengthOfBytes: 20)

        chars = []
        for _ in 0..<charCount {
            let char = try decoder.decode(CHARACTER_INFO.self)
            chars.append(char)
        }
    }
}
