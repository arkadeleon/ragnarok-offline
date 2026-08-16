//
//  AtCommandShortcut.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/14.
//

struct AtCommandShortcut: Identifiable {
    var title: String
    var command: String

    var id: String {
        command
    }
}

struct AtCommandShortcutGroup: Identifiable {
    var title: String
    var shortcuts: [AtCommandShortcut]

    var id: String {
        title
    }
}

extension AtCommandShortcutGroup {
    static let allGroups: [AtCommandShortcutGroup] = [
        AtCommandShortcutGroup(
            title: "Basic",
            shortcuts: [
                AtCommandShortcut(title: "Base +1", command: "@blvl 1"),
                AtCommandShortcut(title: "Job +1", command: "@jlvl 1"),
                AtCommandShortcut(title: "Zeny +10000", command: "@zeny 10000"),
                AtCommandShortcut(title: "Autoloot", command: "@autoloot"),
            ]
        ),
        AtCommandShortcutGroup(
            title: "Stats",
            shortcuts: [
                AtCommandShortcut(title: "STR +1", command: "@str 1"),
                AtCommandShortcut(title: "AGI +1", command: "@agi 1"),
                AtCommandShortcut(title: "VIT +1", command: "@vit 1"),
                AtCommandShortcut(title: "INT +1", command: "@int 1"),
                AtCommandShortcut(title: "DEX +1", command: "@dex 1"),
                AtCommandShortcut(title: "LUK +1", command: "@luk 1"),
            ]
        ),
        AtCommandShortcutGroup(
            title: "Job",
            shortcuts: [
                AtCommandShortcut(title: "Swordman", command: "@job 1"),
                AtCommandShortcut(title: "Magician", command: "@job 2"),
                AtCommandShortcut(title: "Archer", command: "@job 3"),
                AtCommandShortcut(title: "Acolyte", command: "@job 4"),
                AtCommandShortcut(title: "Merchant", command: "@job 5"),
                AtCommandShortcut(title: "Thief", command: "@job 6"),
            ]
        ),
        AtCommandShortcutGroup(
            title: "Monsters",
            shortcuts: [
                AtCommandShortcut(title: "Dummy", command: "@spawn 21077"),
                AtCommandShortcut(title: "Porings ×5", command: "@spawn 1002 5"),
                AtCommandShortcut(title: "Plants ×5", command: "@spawn 1080 5"),
                AtCommandShortcut(title: "Baphomet", command: "@spawn 1039"),
            ]
        ),
        AtCommandShortcutGroup(
            title: "Misc",
            shortcuts: [
                AtCommandShortcut(title: "Heal", command: "@heal"),
                AtCommandShortcut(title: "Resurrect", command: "@alive"),
                AtCommandShortcut(title: "Mount", command: "@mount"),
            ]
        ),
    ]
}
