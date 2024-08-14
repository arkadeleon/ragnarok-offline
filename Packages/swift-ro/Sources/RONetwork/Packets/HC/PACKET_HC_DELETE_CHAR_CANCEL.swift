//
//  PACKET_HC_DELETE_CHAR_CANCEL.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/14.
//

/// See `chclif_char_delete2_cancel_ack`
public struct PACKET_HC_DELETE_CHAR_CANCEL: DecodablePacket {
    public static var packetType: UInt16 {
        0x82c
    }

    public var packetLength: UInt16 {
        10
    }

    public var gid: UInt32
    public var result: UInt32

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        gid = try decoder.decode(UInt32.self)
        result = try decoder.decode(UInt32.self)
    }
}
