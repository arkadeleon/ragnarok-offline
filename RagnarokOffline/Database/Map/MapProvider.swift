//
//  MapProvider.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/4.
//

import RODatabase

struct MapProvider: DatabaseRecordProvider {
    func records(for mode: DatabaseMode) async -> [ObservableMap] {
        let database = MapDatabase.database(for: mode)
        let maps = await database.maps().map { map in
            ObservableMap(mode: mode, map: map)
        }
        return maps
    }

    func records(matching searchText: String, in maps: [ObservableMap]) async -> [ObservableMap] {
        maps.filter { map in
            map.displayName.localizedStandardContains(searchText)
        }
    }
}

extension DatabaseRecordProvider where Self == MapProvider {
    static var map: MapProvider {
        MapProvider()
    }
}
