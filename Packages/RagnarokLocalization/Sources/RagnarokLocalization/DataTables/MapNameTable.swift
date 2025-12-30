//
//  MapNameTable.swift
//  RagnarokLocalization
//
//  Created by Leon Li on 2024/5/27.
//

import Foundation

final public class MapNameTable {
    let mapNamesByRSW: [String : String]

    public init(locale: Locale = .current) {
        guard let url = Bundle.module.url(forResource: "MapName", withExtension: "json", locale: locale) else {
            self.mapNamesByRSW = [:]
            return
        }

        do {
            let decoder = JSONDecoder()
            let data = try Data(contentsOf: url)
            self.mapNamesByRSW = try decoder.decode([String : String].self, from: data)
        } catch {
            self.mapNamesByRSW = [:]
        }
    }

    public func localizedMapName(forMapName mapName: String) -> String? {
        mapNamesByRSW[mapName]
    }
}
