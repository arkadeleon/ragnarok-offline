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
                AtCommandShortcut(title: "Base +10", command: "@blvl 10"),
                AtCommandShortcut(title: "Job +10", command: "@jlvl 10"),
                AtCommandShortcut(title: "Zeny +10,000", command: "@zeny 10000"),
                AtCommandShortcut(title: "Autoloot", command: "@autoloot"),
            ]
        ),
        AtCommandShortcutGroup(
            title: "Stats",
            shortcuts: [
                AtCommandShortcut(title: "STR +10", command: "@str 10"),
                AtCommandShortcut(title: "AGI +10", command: "@agi 10"),
                AtCommandShortcut(title: "VIT +10", command: "@vit 10"),
                AtCommandShortcut(title: "INT +10", command: "@int 10"),
                AtCommandShortcut(title: "DEX +10", command: "@dex 10"),
                AtCommandShortcut(title: "LUK +10", command: "@luk 10"),
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
