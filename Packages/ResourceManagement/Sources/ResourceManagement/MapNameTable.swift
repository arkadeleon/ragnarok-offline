//
//  MapNameTable.swift
//  ResourceManagement
//
//  Created by Leon Li on 2024/5/27.
//

import Foundation

final public class MapNameTable: LocalizedResource {
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
        let resourceIdentifier = "MapNameTable-\(localeIdentifier)"

        return await cache.resource(forIdentifier: resourceIdentifier) {
            if let url = Bundle.module.url(forResource: "MapName", withExtension: "json", locale: locale),
               let mapNameTable = try? MapNameTable(contentsOf: url) {
                return mapNameTable
            } else {
                return MapNameTable()
            }
        }
    }
}
