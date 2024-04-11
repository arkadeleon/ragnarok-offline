//
//  MapCache.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/11.
//

import Foundation
import rAthenaCommon
import rAthenaResource

actor MapCache {
    let mode: ServerMode

    private(set) var maps: [Map] = []
    private(set) var mapsByNames: [String : Map] = [:]

    init(mode: ServerMode) {
        self.mode = mode
    }

    func restoreMaps() throws {
        guard maps.isEmpty else {
            return
        }

        let url = ResourceBundle.shared.dbURL.appendingPathComponent("map_index.txt")
        let string = try String(contentsOf: url)

        var index = 0
        for line in string.split(separator: "\n") {
            if line.trimmingCharacters(in: .whitespacesAndNewlines).starts(with: "//") {
                continue
            }
            let columns = line.split(separator: " ")
            if columns.count == 2 {
                let name = String(columns[0])
                index = Int(columns[1]) ?? 1
                let map = Map(name: name, index: index)
                maps.append(map)
            } else if columns.count == 1 {
                let name = String(columns[0])
                index += 1
                let map = Map(name: name, index: index)
                maps.append(map)
            }
        }

        mapsByNames = Dictionary(maps.map({ ($0.name, $0) }), uniquingKeysWith: { (first, _) in first })
    }
}
