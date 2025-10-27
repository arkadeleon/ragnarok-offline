//
//  MP3NameTable.swift
//  RagnarokResources
//
//  Created by Leon Li on 2025/2/1.
//

import BinaryIO
import Foundation

final public class MP3NameTable: Resource {
    let mp3NamesByRSW: [String : String]

    init(mp3NamesByRSW: [String : String] = [:]) {
        self.mp3NamesByRSW = mp3NamesByRSW
    }

    public func mp3Name(forMapName mapName: String) -> String? {
        mp3NamesByRSW[mapName]
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

            var mp3NamesByRSW: [String : String] = [:]

            let stream = MemoryStream(data: data)

            let reader = StreamReader(stream: stream, delimiter: "\r\n")
            defer {
                reader.close()
            }

            while let line = reader.readLine() {
                if line.trimmingCharacters(in: .whitespaces).starts(with: "//") {
                    continue
                }

                let columns = line.split(separator: "#")
                if columns.count >= 2 {
                    let rsw = columns[0]
                        .replacingOccurrences(of: ".rsw", with: "")
                    let mp3Name = columns[1]
                        .trimmingCharacters(in: .whitespaces)
                        .replacingOccurrences(of: "bgm\\\\", with: "")
                    mp3NamesByRSW[rsw] = mp3Name
                }
            }

            return MP3NameTable(mp3NamesByRSW: mp3NamesByRSW)
        }
    }
}
