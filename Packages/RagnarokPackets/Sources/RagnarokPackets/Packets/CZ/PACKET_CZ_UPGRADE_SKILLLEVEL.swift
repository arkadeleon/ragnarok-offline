//
//  PACKET_CZ_UPGRADE_SKILLLEVEL.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2026/3/1.
//

import BinaryIO

let ENTRY_CZ_UPGRADE_SKILLLEVEL = packetDatabase.entry(forFunctionName: "clif_parse_SkillUp")!

public struct PACKET_CZ_UPGRADE_SKILLLEVEL: EncodablePacket {
    public let packetType: Int16
    public var skillId: UInt16

    public init() {
        packetType = ENTRY_CZ_UPGRADE_SKILLLEVEL.packetType
        skillId = 0
    }

    public func encode(to encoder: BinaryEncoder) throws {
        let packetLength = ENTRY_CZ_UPGRADE_SKILLLEVEL.packetLength
        let offsets = ENTRY_CZ_UPGRADE_SKILLLEVEL.offsets

        var data = [UInt8](repeating: 0, count: Int(packetLength))
        data.replaceSubrange(from: 0, with: packetType)
        data.replaceSubrange(from: offsets[0], with: skillId)

        try encoder.encode(data)
    }
}
