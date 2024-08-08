//
//  PACKET_CZ_PING.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/8.
//

public struct PACKET_CZ_PING: EncodablePacket {
    public static var packetType: UInt16 {
        0x187
    }

    public var packetLength: UInt16 {
        2 + 4
    }

    public var aid: UInt32 = 0

    public init() {
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
        try encoder.encode(aid)
    }
}
