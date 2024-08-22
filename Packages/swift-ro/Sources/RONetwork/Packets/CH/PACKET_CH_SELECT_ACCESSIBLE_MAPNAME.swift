//
//  PACKET_CH_SELECT_ACCESSIBLE_MAPNAME.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/9.
//

public struct PACKET_CH_SELECT_ACCESSIBLE_MAPNAME: EncodablePacket {
    public static var packetType: Int16 {
        0x841
    }

    public var packetLength: Int16 {
        2 + 1 + 1
    }

    public var slot: UInt8
    public var mapNumber: UInt8

    public init() {
        slot = 0
        mapNumber = 0
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
        try encoder.encode(slot)
        try encoder.encode(mapNumber)
    }
}
