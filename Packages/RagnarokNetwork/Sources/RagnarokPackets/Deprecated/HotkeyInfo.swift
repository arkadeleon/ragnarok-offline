//
//  HotkeyInfo.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/8/29.
//

import BinaryIO

@available(*, deprecated, message: "Use generated struct instead.")
public struct _HotkeyInfo: BinaryDecodable, Sendable {

    /// 0: Item, 1: Skill
    public var isSkill: Int8

    /// Item / Skill ID
    public var id: UInt32

    /// Item Quantity / Skill Level
    public var count: Int16

    public init(from decoder: BinaryDecoder) throws {
        isSkill = try decoder.decode(Int8.self)
        id = try decoder.decode(UInt32.self)
        count = try decoder.decode(Int16.self)
    }
}
