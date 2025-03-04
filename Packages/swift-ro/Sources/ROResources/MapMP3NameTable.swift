//
//  MapMP3NameTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/1.
//

import Foundation

public actor MapMP3NameTable {
    public static let `default` = MapMP3NameTable(resourceManager: .default)

    public let resourceManager: ResourceManager

    private var mapMP3NamesByRSW: [String : String] = [:]
    private var isLoaded = false

    public init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager
    }

    public func mapMP3Name(forMapName mapName: String) async -> String? {
        await loadMapMP3NameTable()

        let mapMP3Name = mapMP3NamesByRSW[mapName]
        return mapMP3Name
    }

    private func loadMapMP3NameTable() async {
        if isLoaded {
            return
        }

        let data: Data
        do {
            data = try await resourceManager.contentsOfResource(at: ["data", "mp3nametable.txt"])
        } catch {
            logger.warning("\(error.localizedDescription)")
            return
        }

        guard let string = String(data: data, encoding: .koreanEUC) else {
            return
        }

        let lines = string.split(separator: "\r\n")

        for line in lines {
            if line.trimmingCharacters(in: .whitespacesAndNewlines).starts(with: "//") {
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

        isLoaded = true
    }
}
