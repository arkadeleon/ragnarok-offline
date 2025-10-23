//
//  MapDatabase.swift
//  DatabaseCore
//
//  Created by Leon Li on 2024/3/11.
//

import BinaryIO
import Foundation

public actor MapDatabase {
    public let baseURL: URL
    public let mode: DatabaseMode

    private lazy var _maps: [Map] = {
        metric.beginMeasuring("Load map cache")

        var mapInfos: [String : MapCache.MapInfo] = [:]

        do {
            let mapCacheURLs = [
                baseURL.appending(path: "db/map_cache.dat"),
                baseURL.appending(path: "db/\(mode.path)/map_cache.dat"),
            ]
            for mapCacheURL in mapCacheURLs {
                guard let decoder = BinaryDecoder(url: mapCacheURL) else {
                    continue
                }
                let mapCache = try MapCache(from: decoder)
                for mapInfo in mapCache.maps {
                    mapInfos[mapInfo.name] = mapInfo
                }
            }

            metric.endMeasuring("Load map cache")
        } catch {
            metric.endMeasuring("Load map cache", error)

            return []
        }

        metric.beginMeasuring("Load map index")

        do {
            let url = baseURL.appending(path: "db/map_index.txt")
            let string = try String(contentsOf: url, encoding: .utf8)

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

            metric.endMeasuring("Load map index")

            return maps
        } catch {
            metric.endMeasuring("Load map index", error)

            return []
        }
    }()

    private lazy var _mapsByName: [String : Map] = {
        Dictionary(
            _maps.map({ ($0.name, $0) }),
            uniquingKeysWith: { (first, _) in first }
        )
    }()

    public init(baseURL: URL, mode: DatabaseMode) {
        self.baseURL = baseURL
        self.mode = mode
    }

    public func maps() -> [Map] {
        _maps
    }

    public func map(forName name: String) -> Map? {
        _mapsByName[name]
    }
}
