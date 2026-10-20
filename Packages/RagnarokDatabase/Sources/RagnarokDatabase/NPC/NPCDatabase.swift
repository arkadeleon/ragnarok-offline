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

            var taskCount = 0

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
                    taskGroup.addTask { [taskCount] in
                        (taskCount, try await self.loadScript(at: url))
                    }
                    taskCount += 1
                case "delnpc":
                    try unloadScript(at: url)
                case "import":
                    taskGroup.addTask { [taskCount] in
                        (taskCount, try await self.importScript(at: url))
                    }
                    taskCount += 1
                default:
                    break
                }
            }

            var commandsByTask = [ScriptCommands?](repeating: nil, count: taskCount)
            for try await (taskIndex, commands) in taskGroup {
                commandsByTask[taskIndex] = commands
            }

            var mergedCommands = ScriptCommands()
            for commands in commandsByTask.compactMap({ $0 }) {
                mergedCommands.merge(commands)
            }
            return mergedCommands
        }
    }

    private func loadScript(at url: URL) async throws -> ScriptCommands {
        guard let data = try? Data(contentsOf: url) else {
            throw NPCDatabaseError.invalidFile(url)
        }

        let buffer = [UInt8](data)
        var commands = ScriptCommands()

        var p = skipSpace(in: buffer, from: 0)
        while p < buffer.count {
            var lineEnd = buffer[p...].firstIndex(of: UInt8(ascii: "\n")) ?? buffer.count
            if lineEnd > p && buffer[lineEnd - 1] == UInt8(ascii: "\r") {
                lineEnd -= 1
            }

            let fieldRanges = buffer[p..<lineEnd]
                .split(separator: UInt8(ascii: "\t"))
                .prefix(4)
                .map(\.indices)
            let fields = fieldRanges.map { string(from: buffer[$0]) }

            guard fields.count >= 3 else {
                p = skipSpace(in: buffer, from: lineEnd)
                continue
            }

            let w1 = fields[0]
            let w2 = fields[1]
            let w3 = fields[2]
            var w4 = fields.count >= 4 ? fields[3] : ""

            let type = w2.lowercased()
            var next = lineEnd

            switch type {
            case _ where type.hasPrefix("warp") && fields.count >= 4:
                let warpPoint = WarpPoint(w1, w2, w3, w4)
                commands.warpPoints.append(warpPoint)
            case "shop", "cashshop", "itemshop", "pointshop", "marketshop":
                guard fields.count >= 4 else {
                    break
                }
                let shopNPC = ShopNPC(w1, w2, w3, w4)
                commands.shopNPCs.append(shopNPC)
            case _ where type.hasPrefix("script") && fields.count >= 4:
                guard let scriptEnd = skipScript(in: buffer, from: p) else {
                    return commands
                }
                w4 = string(from: buffer[fieldRanges[3].lowerBound..<scriptEnd])
                next = scriptEnd

                if w1.lowercased() == "function" {
                    if type == "script" {
                        let function = Function(w1, w2, w3, w4)
                        commands.functions.append(function)
                    }
                } else if w1 == "-" {
                    let floatingNPC = FloatingNPC(w1, w2, w3, w4)
                    commands.floatingNPCs.append(floatingNPC)
                } else {
                    let npc = NPC(w1, w2, w3, w4)
                    commands.npcs.append(npc)
                }
            case _ where type.hasPrefix("duplicate(") && fields.count >= 4:
                let duplicate = Duplicate(w1, w2, w3, w4)
                commands.duplicates.append(duplicate)
            case "monster", "boss_monster":
                guard fields.count >= 4 else {
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

            p = skipSpace(in: buffer, from: next)
        }

        return commands
    }

    private func string(from bytes: ArraySlice<UInt8>) -> String {
        String(bytes: bytes, encoding: .isoLatin1)!.trimmingCharacters(in: .whitespaces)
    }

    // Skips whitespaces and comments, like `skip_space` in the official server.
    private func skipSpace(in buffer: [UInt8], from start: Int) -> Int {
        var p = start
        while p < buffer.count {
            if buffer[p] == UInt8(ascii: " ") || (UInt8(ascii: "\t")...UInt8(ascii: "\r")).contains(buffer[p]) {
                p += 1
            } else if buffer[p] == UInt8(ascii: "/") && p + 1 < buffer.count && buffer[p + 1] == UInt8(ascii: "/") {
                p = buffer[p...].firstIndex(of: UInt8(ascii: "\n")) ?? buffer.count
            } else if buffer[p] == UInt8(ascii: "/") && p + 1 < buffer.count && buffer[p + 1] == UInt8(ascii: "*") {
                p += 2
                while p < buffer.count && !(buffer[p] == UInt8(ascii: "*") && p + 1 < buffer.count && buffer[p + 1] == UInt8(ascii: "/")) {
                    p += 1
                }
                p = min(p + 2, buffer.count)
            } else {
                break
            }
        }
        return p
    }

    // Returns the index after the closing curly of the script that starts at the first `{` after `start`,
    // like `npc_skip_script` in the official server.
    private func skipScript(in buffer: [UInt8], from start: Int) -> Int? {
        guard var p = buffer[start...].firstIndex(of: UInt8(ascii: "{")) else {
            return nil
        }

        var curlyCount = 1
        while curlyCount > 0 {
            p = skipSpace(in: buffer, from: p + 1)
            guard p < buffer.count else {
                return nil
            }

            switch buffer[p] {
            case UInt8(ascii: "}"):
                curlyCount -= 1
            case UInt8(ascii: "{"):
                curlyCount += 1
            case UInt8(ascii: "\""):
                p += 1
                while p < buffer.count && buffer[p] != UInt8(ascii: "\"") {
                    if buffer[p] == UInt8(ascii: "\\") {
                        p += 1
                    } else if buffer[p] == UInt8(ascii: "\n") {
                        return nil
                    }
                    p += 1
                }
                guard p < buffer.count else {
                    return nil
                }
            default:
                break
            }
        }

        return p + 1
    }

    private func unloadScript(at url: URL) throws {
    }
}
