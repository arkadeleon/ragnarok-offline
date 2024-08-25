//
//  PACKET_ZC_CHANGE_DIRECTION.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/22.
//

/// See `clif_changed_dir`
public struct PACKET_ZC_CHANGE_DIRECTION: DecodablePacket {
    public static var packetType: Int16 {
        0x9c
    }

    public var packetLength: Int16 {
        9
    }

    public var aid: UInt32
    public var headDir: UInt16
    public var dir: UInt8

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        aid = try decoder.decode(UInt32.self)
        headDir = try decoder.decode(UInt16.self)
        dir = try decoder.decode(UInt8.self)
    }
}
