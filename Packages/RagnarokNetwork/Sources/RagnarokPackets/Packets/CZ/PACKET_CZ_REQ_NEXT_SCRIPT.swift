//
//  PACKET_CZ_REQ_NEXT_SCRIPT.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/11/29.
//

import BinaryIO

public let HEADER_CZ_REQ_NEXT_SCRIPT: Int16 = 0xb9

public struct PACKET_CZ_REQ_NEXT_SCRIPT: BinaryEncodable, Sendable {
    public var packetType: Int16 = 0
    public var npcID: UInt32 = 0

    public init() {
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
        try encoder.encode(npcID)
    }
}
