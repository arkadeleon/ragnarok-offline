//
//  Shortcut.swift
//  RagnarokModels
//
//  Created by Leon Li on 2026/9/10.
//

import RagnarokPackets

public enum Shortcut: Hashable, Sendable {
    case empty
    case item(itemID: Int)
    case skill(skillID: Int, level: Int)

    public init(from hotkey: hotkey_data) {
        let id = Int(hotkey.id)

        if id == 0 {
            self = .empty
        } else if hotkey.isSkill != 0 {
            self = .skill(skillID: id, level: Int(hotkey.count))
        } else {
            self = .item(itemID: id)
        }
    }
}

extension hotkey_data {
    public init(from shortcut: Shortcut) {
        self.init()

        switch shortcut {
        case .empty:
            break
        case .item(let itemID):
            id = UInt32(itemID)
        case .skill(let skillID, let level):
            isSkill = 1
            id = UInt32(skillID)
            count = Int16(level)
        }
    }
}
