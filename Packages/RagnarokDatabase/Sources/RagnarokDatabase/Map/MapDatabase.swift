//
//  MapDatabase.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2024/3/11.
//

import BinaryIO
import Foundation

final public class MapDatabase: Sendable {
    public let baseURL: URL
    public let mode: DatabaseMode

    public init(baseURL: URL, mode: DatabaseMode) {
        self.baseURL = baseURL
        self.mode = mode
    }

    public func maps() async throws -> [Map] {
        metric.beginMeasuring("Load map cache")

        let mapCacheURLs = [
            baseURL.appending(path: "db/map_cache.dat"),
            baseURL.appending(path: "db/\(mode.path)/map_cache.dat"),
        ]

        var mapInfos: [String : MapCache.MapInfo] = [:]
        for mapCacheURL in mapCacheURLs {
            guard let decoder = BinaryDecoder(url: mapCacheURL) else {
                continue
            }
            let mapCache = try decoder.decode(MapCache.self)
            for mapInfo in mapCache.maps {
                mapInfos[mapInfo.name] = mapInfo
            }
        }

        metric.endMeasuring("Load map cache")

        metric.beginMeasuring("Load map index")

        let mapIndexURL = baseURL.appending(path: "db/map_index.txt")
        let mapIndexString = try String(contentsOf: mapIndexURL, encoding: .utf8)

        var index = 0
        var maps: [Map] = []

        for line in mapIndexString.split(separator: "\n") {
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

        metric.endMeasuring("Load map index")

        return maps
    }
}
