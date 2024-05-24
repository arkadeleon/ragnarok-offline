//
//  MapDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/11.
//

import Foundation
import rAthenaCommon
import rAthenaResource

public actor MapDatabase {
    public static let prerenewal = MapDatabase(mode: .prerenewal)
    public static let renewal = MapDatabase(mode: .renewal)

    public static func database(for mode: ServerMode) -> MapDatabase {
        switch mode {
        case .prerenewal: .prerenewal
        case .renewal: .renewal
        }
    }

    public let mode: ServerMode

    private var cachedMaps: [Map] = []
    private var cachedMapsByNames: [String : Map] = [:]

    private init(mode: ServerMode) {
        self.mode = mode
    }

    public func maps() throws -> [Map] {
        if cachedMaps.isEmpty {
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
                    cachedMaps.append(map)
                } else if columns.count == 1 {
                    let name = String(columns[0])
                    index += 1
                    let map = Map(name: name, index: index)
                    cachedMaps.append(map)
                }
            }
        }

        return cachedMaps
    }

    public func map(forName name: String) throws -> Map? {
        if cachedMapsByNames.isEmpty {
            let maps = try maps()
            cachedMapsByNames = Dictionary(maps.map({ ($0.name, $0) }), uniquingKeysWith: { (first, _) in first })
        }

        let map = cachedMapsByNames[name]
        return map
    }
}
