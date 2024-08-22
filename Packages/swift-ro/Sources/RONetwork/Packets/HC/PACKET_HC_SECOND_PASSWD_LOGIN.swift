//
//  PACKET_HC_SECOND_PASSWD_LOGIN.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/12.
//

public struct PACKET_HC_SECOND_PASSWD_LOGIN: DecodablePacket {
    public static var packetType: Int16 {
        0x8b9
    }

    public var packetLength: Int16 {
        12
    }

    public var seed: UInt32
    public var aid: UInt32
    public var state: UInt16

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        seed = try decoder.decode(UInt32.self)
        aid = try decoder.decode(UInt32.self)
        state = try decoder.decode(UInt16.self)
    }
}
