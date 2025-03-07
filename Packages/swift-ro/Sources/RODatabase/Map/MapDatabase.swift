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

    private lazy var _maps: [Map] = {
        var mapInfos: [String : MapCache.MapInfo] = [:]
        let string: String

        do {
            let mapCacheURLs = [
                ServerResourceManager.default.sourceURL
                    .appending(path: "db/map_cache.dat"),
                ServerResourceManager.default.sourceURL
                    .appending(path: "db/\(mode.path)/map_cache.dat"),
            ]
            for mapCacheURL in mapCacheURLs {
                let decoder = try BinaryDecoder(url: mapCacheURL)
                let mapCache = try MapCache(from: decoder)
                for mapInfo in mapCache.maps {
                    mapInfos[mapInfo.name] = mapInfo
                }
            }

            let url = ServerResourceManager.default.sourceURL
                .appending(path: "db/map_index.txt")
            string = try String(contentsOf: url, encoding: .utf8)
        } catch {
            logger.warning("\(error.localizedDescription)")
            return []
        }

        var index = 0
        var maps: [Map] = []

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
            maps.append(map)
        }

        return maps
    }()

    private lazy var _mapsByName: [String : Map] = {
        Dictionary(
            _maps.map({ ($0.name, $0) }),
            uniquingKeysWith: { (first, _) in first }
        )
    }()

    private init(mode: DatabaseMode) {
        self.mode = mode
    }

    public func maps() -> [Map] {
        _maps
    }

    public func map(forName name: String) -> Map? {
        _mapsByName[name]
    }
}
