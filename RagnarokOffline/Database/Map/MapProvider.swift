//
//  MapProvider.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/4.
//

import RODatabase

struct MapProvider: DatabaseRecordProvider {
    func records(for mode: DatabaseMode) async throws -> [Map] {
        let database = MapDatabase.database(for: mode)
        let maps = try await database.maps()
        return maps
    }

    func records(matching searchText: String, in maps: [Map]) async -> [Map] {
        maps.filter { map in
            map.name.localizedStandardContains(searchText)
        }
    }
}

extension DatabaseRecordProvider where Self == MapProvider {
    static var map: MapProvider {
        MapProvider()
    }
}
