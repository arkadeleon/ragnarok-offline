//
//  PACKET_ZC_NPCACK_MAPMOVE.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/22.
//

public struct PACKET_ZC_NPCACK_MAPMOVE: DecodablePacket {
    public static var packetType: UInt16 {
        0x91
    }

    public var packetLength: UInt16 {
        22
    }

    public var mapName: String
    public var xPos: UInt16
    public var yPos: UInt16

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        mapName = try decoder.decode(String.self, length: 16)
        xPos = try decoder.decode(UInt16.self)
        yPos = try decoder.decode(UInt16.self)
    }
}
