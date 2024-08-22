//
//  PACKET_ZC_AID.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/22.
//

public struct PACKET_ZC_AID: DecodablePacket {
    public static var packetType: Int16 {
        0x283
    }

    public var packetLength: Int16 {
        6
    }

    public var aid: UInt32

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        aid = try decoder.decode(UInt32.self)
    }
}
