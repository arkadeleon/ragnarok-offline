//
//  PACKET_CZ_USE_SKILL_TOGROUND.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2026/3/1.
//

import BinaryIO

let ENTRY_CZ_USE_SKILL_TOGROUND = packetDatabase.entry(forFunctionName: "clif_parse_UseSkillToPos")!

public struct PACKET_CZ_USE_SKILL_TOGROUND: EncodablePacket {
    public let packetType: Int16
    public var selectedLevel: UInt16
    public var skillId: UInt16
    public var xPos: Int16
    public var yPos: Int16

    public init() {
        packetType = ENTRY_CZ_USE_SKILL_TOGROUND.packetType
        selectedLevel = 0
        skillId = 0
        xPos = 0
        yPos = 0
    }

    public func encode(to encoder: BinaryEncoder) throws {
        let packetLength = ENTRY_CZ_USE_SKILL_TOGROUND.packetLength
        let offsets = ENTRY_CZ_USE_SKILL_TOGROUND.offsets

        var data = [UInt8](repeating: 0, count: Int(packetLength))
        data.replaceSubrange(from: 0, with: packetType)
        data.replaceSubrange(from: offsets[0], with: selectedLevel)
        data.replaceSubrange(from: offsets[1], with: skillId)
        data.replaceSubrange(from: offsets[2], with: xPos)
        data.replaceSubrange(from: offsets[3], with: yPos)

        try encoder.encode(data)
    }
}
