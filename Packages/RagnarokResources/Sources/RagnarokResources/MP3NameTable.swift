//
//  MP3NameTable.swift
//  RagnarokResources
//
//  Created by Leon Li on 2025/2/1.
//

import BinaryIO
import Foundation

final public class MP3NameTable: Resource {
    let mp3NamesByMapName: [String : String]

    init(mp3NamesByMapName: [String : String] = [:]) {
        self.mp3NamesByMapName = mp3NamesByMapName
    }

    // The map name should contain rsw suffix.
    public func mp3Name(forMapName mapName: String) -> String? {
        mp3NamesByMapName[mapName]
    }
}

extension ResourceManager {
    public func mp3NameTable() async -> MP3NameTable {
        await cache.resource(forIdentifier: "MP3NameTable") { [self] in
            let data: Data
            do {
                data = try await contentsOfResource(at: ["data", "mp3nametable.txt"])
            } catch {
                logger.warning("\(error)")
                return MP3NameTable()
            }

            let stream = MemoryStream(data: data)
            let reader = StreamReader(stream: stream, delimiter: "\r\n")
            defer {
                reader.close()
            }

            var mp3NamesByMapName: [String : String] = [:]

            while let line = reader.readLine() {
                if line.trimmingCharacters(in: .whitespaces).starts(with: "//") {
                    continue
                }

                let columns = line.split(separator: "#")
                if columns.count >= 2 {
                    let mapName = String(columns[0])
                    let mp3Name = columns[1]
                        .trimmingCharacters(in: .whitespaces)
                        .replacingOccurrences(of: "bgm\\\\", with: "")
                    mp3NamesByMapName[mapName] = mp3Name
                }
            }

            return MP3NameTable(mp3NamesByMapName: mp3NamesByMapName)
        }
    }
}
