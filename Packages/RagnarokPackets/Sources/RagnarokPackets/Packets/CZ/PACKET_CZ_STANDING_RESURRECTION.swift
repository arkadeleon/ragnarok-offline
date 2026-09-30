//
//  PACKET_CZ_STANDING_RESURRECTION.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2026/9/30.
//

import BinaryIO

let ENTRY_CZ_STANDING_RESURRECTION = packetDatabase.entry(forFunctionName: "clif_parse_AutoRevive")!

public struct PACKET_CZ_STANDING_RESURRECTION: EncodablePacket {
    public let packetType: Int16

    public init() {
        packetType = ENTRY_CZ_STANDING_RESURRECTION.packetType
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(packetType)
    }
}
