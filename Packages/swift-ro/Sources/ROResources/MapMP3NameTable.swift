//
//  MapMP3NameTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/1.
//

import BinaryIO
import Foundation

public actor MapMP3NameTable {
    package let resourceManager: ResourceManager

    private var loadTask: Task<[String : String], Never>?

    public init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager
    }

    public func mapMP3Name(forMapName mapName: String) async -> String? {
        let mapMP3NamesByRSW = await loadTable()
        let mapMP3Name = mapMP3NamesByRSW[mapName]
        return mapMP3Name
    }

    private func loadTable() async -> [String : String] {
        if let task = loadTask {
            return await task.value
        }

        let task = Task<[String : String], Never> {
            let data: Data
            do {
                data = try await resourceManager.contentsOfResource(at: ["data", "mp3nametable.txt"])
            } catch {
                logger.warning("\(error.localizedDescription)")
                return [:]
            }

            var mapMP3NamesByRSW: [String : String] = [:]

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
                    let mapMP3Name = columns[1]
                        .trimmingCharacters(in: .whitespaces)
                        .replacingOccurrences(of: "bgm\\\\", with: "")
                    mapMP3NamesByRSW[rsw] = mapMP3Name
                }
            }

            return mapMP3NamesByRSW
        }
        loadTask = task

        return await task.value
    }
}
