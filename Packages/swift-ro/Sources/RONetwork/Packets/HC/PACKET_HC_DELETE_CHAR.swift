//
//  PACKET_HC_DELETE_CHAR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/8.
//

/// See `chclif_char_delete2_accept_ack`
public struct PACKET_HC_DELETE_CHAR: DecodablePacket {
    public static var packetType: Int16 {
        0x82a
    }

    public var packetLength: Int16 {
        2 + 4 + 4
    }

    public var charID: UInt32
    public var result: UInt32

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        charID = try decoder.decode(UInt32.self)
        result = try decoder.decode(UInt32.self)
    }
}
