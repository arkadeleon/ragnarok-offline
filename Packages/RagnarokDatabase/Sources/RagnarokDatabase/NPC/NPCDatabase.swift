//
//  NPCDatabase.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2024/3/11.
//

import BinaryIO
import Foundation

enum NPCDatabaseError: Error {
    case invalidFile(URL)
}

final public class NPCDatabase: Sendable {
    public let baseURL: URL
    public let mode: DatabaseMode

    public init(baseURL: URL, mode: DatabaseMode) {
        self.baseURL = baseURL
        self.mode = mode
    }

    public func scriptCommands() async throws -> ScriptCommands {
        metric.beginMeasuring("Load NPC database")

        let url = baseURL.appending(path: "npc/\(mode.path)/scripts_main.conf")
        let scriptCommands = try await importScript(at: url)

        metric.endMeasuring("Load NPC database")

        return scriptCommands
    }

    private func importScript(at url: URL) async throws -> ScriptCommands {
        try await withThrowingTaskGroup { taskGroup in
            guard let stream = FileStream(forReadingFrom: url) else {
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
                let url = baseURL.appending(path: w2)

                switch w1 {
                case "npc":
                    taskGroup.addTask {
                        try await self.loadScript(at: url)
                    }
                case "delnpc":
                    try unloadScript(at: url)
                case "import":
                    taskGroup.addTask {
                        try await self.importScript(at: url)
                    }
                default:
                    break
                }
            }

            var mergedCommands = ScriptCommands()
            for try await commands in taskGroup {
                mergedCommands.merge(commands)
            }
            return mergedCommands
        }
    }

    private func loadScript(at url: URL) async throws -> ScriptCommands {
        guard let stream = FileStream(forReadingFrom: url) else {
            throw NPCDatabaseError.invalidFile(url)
        }

        let reader = StreamReader(stream: stream)
        defer {
            reader.close()
        }

        var commands = ScriptCommands()

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
                commands.warpPoints.append(warpPoint)
            case "shop", "cashshop", "itemshop", "pointshop", "marketshop":
                guard words.count >= 4 else {
                    break
                }
                let shopNPC = ShopNPC(w1, w2, w3, w4)
                commands.shopNPCs.append(shopNPC)
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
                    commands.functions.append(function)
                } else if w1 == "-" {
                    let floatingNPC = FloatingNPC(w1, w2, w3, w4)
                    commands.floatingNPCs.append(floatingNPC)
                } else {
                    let npc = NPC(w1, w2, w3, w4)
                    commands.npcs.append(npc)
                }
            case let w2 where w2.starts(with: "duplicate"):
                guard words.count >= 4 else {
                    break
                }
                let duplicate = Duplicate(w1, w2, w3, w4)
                commands.duplicates.append(duplicate)
            case "monster", "boss_monster":
                guard words.count >= 4 else {
                    break
                }
                let monsterSpawn = MonsterSpawn(w1, w2, w3, w4)
                commands.monsterSpawns.append(monsterSpawn)
            case "mapflag":
                let mapFlag = MapFlag(w1, w2, w3, w4)
                commands.mapFlags.append(mapFlag)
            default:
                break
            }
        }

        return commands
    }

    private func unloadScript(at url: URL) throws {
    }
}
