//
//  PACKET_CZ_CLOSE_DIALOG.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/29.
//

import ROCore

public let HEADER_CZ_CLOSE_DIALOG: Int16 = 0x146

public struct PACKET_CZ_CLOSE_DIALOG: BinaryEncodable {
    public var packetType: Int16 = 0
    public var npcID: UInt32 = 0

    public init() {
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
        try encoder.encode(npcID)
    }
}
