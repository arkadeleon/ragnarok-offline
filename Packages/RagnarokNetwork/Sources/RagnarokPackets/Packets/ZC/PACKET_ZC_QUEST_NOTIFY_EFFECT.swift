//
//  PACKET_ZC_QUEST_NOTIFY_EFFECT.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2025/3/26.
//

import BinaryIO

public let HEADER_ZC_QUEST_NOTIFY_EFFECT: Int16 = 0x446

public struct PACKET_ZC_QUEST_NOTIFY_EFFECT: BinaryDecodable, Sendable {
    public var packetType: Int16
    public var npcID: UInt32
    public var x: Int16
    public var y: Int16
    public var effect: Int16
    public var color: Int16

    public init(from decoder: BinaryDecoder) throws {
        packetType = try decoder.decode(Int16.self)
        npcID = try decoder.decode(UInt32.self)
        x = try decoder.decode(Int16.self)
        y = try decoder.decode(Int16.self)
        effect = try decoder.decode(Int16.self)
        color = try decoder.decode(Int16.self)
    }
}
