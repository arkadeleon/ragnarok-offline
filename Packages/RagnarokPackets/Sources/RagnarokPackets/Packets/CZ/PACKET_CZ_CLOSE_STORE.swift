//
//  PACKET_CZ_CLOSE_STORE.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2026/9/26.
//

import BinaryIO

let ENTRY_CZ_CLOSE_STORE = packetDatabase.entry(forFunctionName: "clif_parse_CloseKafra")!

public struct PACKET_CZ_CLOSE_STORE: EncodablePacket {
    public let packetType: Int16

    public init() {
        packetType = ENTRY_CZ_CLOSE_STORE.packetType
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
    }
}
