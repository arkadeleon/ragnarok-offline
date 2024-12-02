//
//  MapDatabase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/11.
//

import Foundation
import rAthenaResources
import ROCore

public actor MapDatabase {
    public static let prerenewal = MapDatabase(mode: .prerenewal)
    public static let renewal = MapDatabase(mode: .renewal)

    public static func database(for mode: DatabaseMode) -> MapDatabase {
        switch mode {
        case .prerenewal: .prerenewal
        case .renewal: .renewal
        }
    }

    public let mode: DatabaseMode

    private var cachedMaps: [Map] = []
    private var cachedMapsByName: [String : Map] = [:]

    private init(mode: DatabaseMode) {
        self.mode = mode
    }

    public func maps() throws -> [Map] {
        if cachedMaps.isEmpty {
            var mapInfos: [String : MapCache.MapInfo] = [:]
            let mapCacheURLs = [
                ServerResourceManager.default.dbURL
                    .appendingPathComponent("map_cache.dat"),
                ServerResourceManager.default.dbURL
                    .appendingPathComponent(mode.path)
                    .appendingPathComponent("map_cache.dat"),
            ]
            for mapCacheURL in mapCacheURLs {
                let decoder = try BinaryDecoder(url: mapCacheURL)
                let mapCache = try MapCache(from: decoder)
                for mapInfo in mapCache.maps {
                    mapInfos[mapInfo.name] = mapInfo
                }
            }

            let url = ServerResourceManager.default.dbURL
                .appendingPathComponent("map_index.txt")
            let string = try String(contentsOf: url)

            var index = 0
            for line in string.split(separator: "\n") {
                if line.trimmingCharacters(in: .whitespacesAndNewlines).starts(with: "//") {
                    continue
                }

                let columns = line.split(separator: " ")
                if columns.count == 2 {
                    index = Int(columns[1]) ?? 1
                } else if columns.count == 1 {
                    index += 1
                } else {
                    continue
                }

                let name = String(columns[0])
                guard let mapInfo = mapInfos[name] else {
                    continue
                }

                let map = Map(name: name, index: index, info: mapInfo)
                cachedMaps.append(map)
            }
        }

        return cachedMaps
    }

    public func map(forName name: String) throws -> Map? {
        if cachedMapsByName.isEmpty {
            let maps = try maps()
            cachedMapsByName = Dictionary(maps.map({ ($0.name, $0) }), uniquingKeysWith: { (first, _) in first })
        }

        let map = cachedMapsByName[name]
        return map
    }
}
