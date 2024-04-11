//
//  ScriptCache.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/11.
//

import Foundation
import rAthenaCommon
import rAthenaResource

actor ScriptCache {
    let mode: ServerMode

    private(set) var mapFlags: [MapFlag] = []
    private(set) var monsterSpawns: [MonsterSpawn] = []
    private(set) var warpPoints: [WarpPoint] = []
    private(set) var npcs: [NPC] = []
    private(set) var floatingNPCs: [FloatingNPC] = []
    private(set) var shopNPCs: [ShopNPC] = []
    private(set) var duplicates: [Duplicate] = []
    private(set) var functions: [Function] = []

    private var isRestored = false

    init(mode: ServerMode) {
        self.mode = mode
    }

    func restoreScripts() throws {
        guard !isRestored else {
            return
        }

        let url = ResourceBundle.shared.npcURL
            .appendingPathComponent(mode.dbPath)
            .appendingPathComponent("scripts_main.conf")
        try import_conf_file(url: url)

        isRestored = true
    }

    private func import_conf_file(url: URL) throws {
        let string = try String(contentsOf: url, encoding: .ascii)
        let lines = string.split(separator: "\n")

        for line in lines {
            let line = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if line.isEmpty || line.starts(with: "//") {
                continue
            }

            let words = line.components(separatedBy: ": ")
            guard words.count == 2 else {
                continue
            }

            let w1 = words[0]
            let w2 = words[1]
            let url = ResourceBundle.shared.url.appendingPathComponent(w2)

            switch w1 {
            case "npc":
                try add_npc_file(url: url)
            case "delnpc":
                try del_npc_file(url: url)
            case "import":
                try import_conf_file(url: url)
            default:
                break
            }
        }
    }

    private func add_npc_file(url: URL) throws {
        let string = try String(contentsOf: url, encoding: .ascii)
        let scanner = Scanner(string: string)
        scanner.charactersToBeSkipped = nil

        while !scanner.isAtEnd {
            let line = scanner.scanLine().trimmingCharacters(in: .whitespaces)
            if line.isEmpty || line.starts(with: "//") {
                continue
            }

            if line.starts(with: "/*") {
                _ = scanner.scanUpToString("*/")
                _ = scanner.scanString("*/")
                continue
            }

            let words = line.split(separator: "\t")
            guard words.count >= 3 else {
                continue
            }

            let w1 = words[0].trimmingCharacters(in: .whitespaces)
            let w2 = words[1].trimmingCharacters(in: .whitespaces)
            let w3 = words[2].trimmingCharacters(in: .whitespaces)

            if w1 != "-" && w1.lowercased() != "function" {
                // <map name>,<x>,<y>,<facing>
            }

            switch w2.lowercased() {
            case "warp", "warp2":
                guard words.count > 3 else {
                    break
                }
                let w4 = words[3].trimmingCharacters(in: .whitespaces)
                let warpPoint = WarpPoint(w1, w2, w3, w4)
                warpPoints.append(warpPoint)
            case "shop", "cashshop", "itemshop", "pointshop", "marketshop":
                guard words.count > 3 else {
                    break
                }
                let w4 = words[3].trimmingCharacters(in: .whitespaces)
                let shopNPC = ShopNPC(w1, w2, w3, w4)
                shopNPCs.append(shopNPC)
            case "script":
                guard words.count > 3 else {
                    break
                }
                var w4 = words[3].trimmingCharacters(in: .whitespaces)
                let code = scanner.scanUpToString("\n}") ?? ""
                _ = scanner.scanString("\n}")
                w4 = w4 + "\n" + code + "\n}"
                if w1 == "function" {
                    let function = Function(w1, w2, w3, w4)
                    functions.append(function)
                } else if w1 == "-" {
                    let floatingNPC = FloatingNPC(w1, w2, w3, w4)
                    floatingNPCs.append(floatingNPC)
                } else {
                    let npc = NPC(w1, w2, w3, w4)
                    npcs.append(npc)
                }
            case let w2 where w2.starts(with: "duplicate"):
                guard words.count > 3 else {
                    break
                }
                let w4 = words[3].trimmingCharacters(in: .whitespaces)
                let duplicate = Duplicate(w1, w2, w3, w4)
                duplicates.append(duplicate)
            case "monster", "boss_monster":
                guard words.count > 3 else {
                    break
                }
                let w4 = words[3].trimmingCharacters(in: .whitespaces)
                let monsterSpawn = MonsterSpawn(w1, w2, w3, w4)
                monsterSpawns.append(monsterSpawn)
            case "mapflag":
                let w4 = words.count > 3 ? words[3].trimmingCharacters(in: .whitespaces) : nil
                let mapFlag = MapFlag(w1, w2, w3, w4)
                mapFlags.append(mapFlag)
            default:
                break
            }
        }
    }

    private func del_npc_file(url: URL) throws {
    }
}

extension Scanner {
    func scanLine() -> String {
        var line = ""
        while !isAtEnd {
            guard let character = scanCharacter() else {
                break
            }
            if character.isNewline {
                break
            } else {
                line.append(character)
            }
        }
        return line
    }
}
