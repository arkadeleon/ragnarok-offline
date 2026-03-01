//
//  PACKET_CZ_USE_SKILL.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2026/3/1.
//

import BinaryIO

let ENTRY_CZ_USE_SKILL = packetDatabase.entry(forFunctionName: "clif_parse_UseSkillToId")!

public struct PACKET_CZ_USE_SKILL: EncodablePacket {
    public let packetType: Int16
    public var selectedLevel: UInt16
    public var skillId: UInt16
    public var targetId: UInt32

    public init() {
        packetType = ENTRY_CZ_USE_SKILL.packetType
        selectedLevel = 0
        skillId = 0
        targetId = 0
    }

    public func encode(to encoder: BinaryEncoder) throws {
        let packetLength = ENTRY_CZ_USE_SKILL.packetLength
        let offsets = ENTRY_CZ_USE_SKILL.offsets

        var data = [UInt8](repeating: 0, count: Int(packetLength))
        data.replaceSubrange(from: 0, with: packetType)
        data.replaceSubrange(from: offsets[0], with: selectedLevel)
        data.replaceSubrange(from: offsets[1], with: skillId)
        data.replaceSubrange(from: offsets[2], with: targetId)

        try encoder.encode(data)
    }
}
