//
//  NPCDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/11.
//

import Foundation
import rAthenaResources
import ROCore

enum NPCDatabaseError: Error {
    case invalidFile(URL)
}

public actor NPCDatabase {
    public static let prerenewal = NPCDatabase(mode: .prerenewal)
    public static let renewal = NPCDatabase(mode: .renewal)

    public static func database(for mode: DatabaseMode) -> NPCDatabase {
        switch mode {
        case .prerenewal: .prerenewal
        case .renewal: .renewal
        }
    }

    public let mode: DatabaseMode

    private var mapFlags: [MapFlag] = []
    private var monsterSpawns: [MonsterSpawn] = []
    private var warpPoints: [WarpPoint] = []
    private var npcs: [NPC] = []
    private var floatingNPCs: [FloatingNPC] = []
    private var shopNPCs: [ShopNPC] = []
    private var duplicates: [Duplicate] = []
    private var functions: [Function] = []

    private var isCached = false

    private init(mode: DatabaseMode) {
        self.mode = mode
    }

    public func monsterSpawns(for monster: Monster) -> [MonsterSpawn] {
        restoreScripts()

        let monsterSpawns = monsterSpawns.filter { monsterSpawn in
            monsterSpawn.monsterID == monster.id || monsterSpawn.monsterAegisName == monster.aegisName
        }
        return monsterSpawns
    }

    public func monsterSpawns(forMapName mapName: String) -> [MonsterSpawn] {
        restoreScripts()

        let monsterSpawns = monsterSpawns.filter { monsterSpawn in
            monsterSpawn.mapName == mapName
        }
        return monsterSpawns
    }

    private func restoreScripts() {
        if !isCached {
            metric.beginMeasuring("Load NPC database")

            do {
                let url = ServerResourceManager.default.sourceURL
                    .appending(path: "npc/\(mode.path)/scripts_main.conf")
                try import_conf_file(url: url)

                metric.endMeasuring("Load NPC database")
            } catch {
                metric.endMeasuring("Load NPC database", error)
            }

            isCached = true
        }
    }

    private func import_conf_file(url: URL) throws {
        guard let stream = FileStream(url: url) else {
            throw NPCDatabaseError.invalidFile(url)
        }

        let reader = StreamReader(stream: stream)
        defer {
            reader.close()
        }

        while let line = reader.readLine() {
            let line = line.trimmingCharacters(in: .whitespaces)
            if line.isEmpty || line.starts(with: "//") {
                continue
            }

            let words = line.components(separatedBy: ": ")
            guard words.count == 2 else {
                continue
            }

            let w1 = words[0]
            let w2 = words[1]
            let url = ServerResourceManager.default.sourceURL
                .appending(path: w2)

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
        guard let stream = FileStream(url: url) else {
            throw NPCDatabaseError.invalidFile(url)
        }

        let reader = StreamReader(stream: stream)
        defer {
            reader.close()
        }

        while let line = reader.readLine() {
            let line = line.trimmingCharacters(in: .whitespaces)
            if line.isEmpty || line.starts(with: "//") {
                continue
            }

            // `/*` and `*/` is on the same line.
            if line.hasPrefix("/*") && line.hasSuffix("*/") {
                continue
            }

            // `/*` and `*/` is not on the same line.
            if line.hasPrefix("/*") {
                while let line = reader.readLine() {
                    if line.hasSuffix("*/") {
                        break
                    }
                }
                continue
            }

            let words = line.split(separator: "\t")
            guard words.count >= 3 else {
                continue
            }

            let w1 = words[0].trimmingCharacters(in: .whitespaces)
            let w2 = words[1].trimmingCharacters(in: .whitespaces)
            let w3 = words[2].trimmingCharacters(in: .whitespaces)

            var w4 = ""
            if words.count >= 4 {
                w4 = words[3].trimmingCharacters(in: .whitespaces)
            }

            if w1 != "-" && w1.lowercased() != "function" {
                // <map name>,<x>,<y>,<facing>
            }

            switch w2.lowercased() {
            case "warp", "warp2":
                guard words.count >= 4 else {
                    break
                }
                let warpPoint = WarpPoint(w1, w2, w3, w4)
                warpPoints.append(warpPoint)
            case "shop", "cashshop", "itemshop", "pointshop", "marketshop":
                guard words.count >= 4 else {
                    break
                }
                let shopNPC = ShopNPC(w1, w2, w3, w4)
                shopNPCs.append(shopNPC)
            case "script":
                guard words.count >= 4 else {
                    break
                }
                while let line = reader.readLine() {
                    w4.append("\n")
                    w4.append(line)
                    if line == "}" {
                        break
                    }
                }
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
                guard words.count >= 4 else {
                    break
                }
                let duplicate = Duplicate(w1, w2, w3, w4)
                duplicates.append(duplicate)
            case "monster", "boss_monster":
                guard words.count >= 4 else {
                    break
                }
                let monsterSpawn = MonsterSpawn(w1, w2, w3, w4)
                monsterSpawns.append(monsterSpawn)
            case "mapflag":
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
