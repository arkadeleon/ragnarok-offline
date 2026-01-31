//
//  PACKET_ZC_HP_INFO.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2026/1/31.
//

import BinaryIO

public struct PACKET_ZC_HP_INFO: DecodablePacket {
    public var packetType: Int16
    public var GID: UInt32
    public var HP: Int32
    public var maxHP: Int32

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
        GID = try decoder.decode(UInt32.self)
        HP = try decoder.decode(Int32.self)
        maxHP = try decoder.decode(Int32.self)
    }
}
