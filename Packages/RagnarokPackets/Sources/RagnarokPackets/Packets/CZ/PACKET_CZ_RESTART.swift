//
//  PACKET_CZ_RESTART.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2025/10/16.
//

import BinaryIO

let ENTRY_CZ_RESTART = packetDatabase.entry(forFunctionName: "clif_parse_Restart")!

public struct PACKET_CZ_RESTART: EncodablePacket {
    public let packetType: Int16
    public var type: UInt8

    public init() {
        packetType = ENTRY_CZ_RESTART.packetType
        type = 0
    }

    public func encode(to encoder: BinaryEncoder) throws {
        let packetLength = ENTRY_CZ_RESTART.packetLength
        let offsets = ENTRY_CZ_RESTART.offsets

        var data = [UInt8](repeating: 0, count: Int(packetLength))
        data.replaceSubrange(from: 0, with: packetType)
        data.replaceSubrange(from: offsets[0], with: type)

        try encoder.encode(data)
    }
}
