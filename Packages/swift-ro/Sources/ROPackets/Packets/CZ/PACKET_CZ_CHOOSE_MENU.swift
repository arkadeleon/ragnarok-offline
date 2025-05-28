//
//  PACKET_CZ_CHOOSE_MENU.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/6.
//

import BinaryIO

public let HEADER_CZ_CHOOSE_MENU: Int16 = 0xb8

public struct PACKET_CZ_CHOOSE_MENU: BinaryEncodable {
    public var packetType: Int16 = 0
    public var npcID: UInt32 = 0
    public var select: UInt8 = 0

    public init() {
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
        try encoder.encode(npcID)
        try encoder.encode(select)
    }
}
