//
//  MapNameTable.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/27.
//

import Foundation

final public class MapNameTable: Resource {
    let mapNamesByRSW: [String : String]

    init() {
        self.mapNamesByRSW = [:]
    }

    init(contentsOf url: URL) throws {
        let decoder = JSONDecoder()
        let data = try Data(contentsOf: url)
        self.mapNamesByRSW = try decoder.decode([String : String].self, from: data)
    }

    public func localizedMapName(forMapName mapName: String) -> String? {
        mapNamesByRSW[mapName]
    }
}

extension ResourceManager {
    public func mapNameTable(for locale: Locale) async -> MapNameTable {
        let localeIdentifier = locale.identifier(.bcp47)
        let taskIdentifier = "MapNameTable-\(localeIdentifier)"

        if let task = tasks.withLock({ $0[taskIdentifier] }) {
            return await task.value as! MapNameTable
        }

        let task = Task<any Resource, Never> {
            if let url = Bundle.module.url(forResource: "MapName", withExtension: "json", locale: locale),
               let mapNameTable = try? MapNameTable(contentsOf: url) {
                return mapNameTable
            } else {
                return MapNameTable()
            }
        }

        tasks.withLock {
            $0[taskIdentifier] = task
        }

        return await task.value as! MapNameTable
    }
}
