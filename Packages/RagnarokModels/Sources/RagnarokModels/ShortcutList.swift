//
//  ShortcutList.swift
//  RagnarokModels
//
//  Created by Leon Li on 2026/9/10.
//

import RagnarokPackets

private let columnCount = 9
private let rowCount = 4

public struct ShortcutChange: Equatable, Sendable {
    public var index: Int
    public var shortcut: Shortcut
}

public struct ShortcutList: Equatable, Sendable {
    public private(set) var rows: [[Shortcut]]

    /// The row the official client displays first.
    ///
    /// See `hotkey_rowshift`.
    public var rowShift: Int

    /// The rows which hold at least one shortcut.
    public var nonEmptyRows: [Int] {
        rows.indices.filter { row in
            !rows[row].allSatisfy({ $0 == .empty })
        }
    }

    public init() {
        let row: [Shortcut] = Array(repeating: .empty, count: columnCount)
        rows = Array(repeating: row, count: rowCount)
        rowShift = 0
    }

    public mutating func update(from packet: PACKET_ZC_SHORTCUT_KEY_LIST) {
        guard packet.tab == 0 else {
            return
        }

        rows = (0..<rowCount).map { row in
            let start = row * columnCount
            return packet.hotkey[start..<(start + columnCount)].map(Shortcut.init(from:))
        }
        rowShift = Int(packet.rotate)
    }

    /// Assigns `shortcut` to the slot at `row` and `column`, clearing any other slot of
    /// the same row that already holds it.
    public mutating func setShortcut(_ shortcut: Shortcut, atRow row: Int, column: Int) {
        if shortcut != .empty {
            for duplicateColumn in rows[row].indices
            where duplicateColumn != column && rows[row][duplicateColumn] == shortcut {
                rows[row][duplicateColumn] = .empty
            }
        }

        rows[row][column] = shortcut
    }

    /// The slots which differ from the ones of `shortcutList`.
    public func changes(from shortcutList: ShortcutList) -> [ShortcutChange] {
        var changes: [ShortcutChange] = []

        for (row, shortcuts) in rows.enumerated() {
            for (column, shortcut) in shortcuts.enumerated()
            where shortcut != shortcutList.rows[row][column] {
                let change = ShortcutChange(index: row * columnCount + column, shortcut: shortcut)
                changes.append(change)
            }
        }

        return changes
    }
}
