//
//  MapProvider.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/4.
//

import RODatabase

struct MapProvider: DatabaseRecordProvider {
    func records(for mode: DatabaseMode) async -> [MapModel] {
        let database = MapDatabase.shared
        let maps = await database.maps().map { map in
            MapModel(mode: mode, map: map)
        }
        for map in maps {
            await map.fetchLocalizedName()
        }
        return maps
    }

    func records(matching searchText: String, in maps: [MapModel]) async -> [MapModel] {
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

extension DatabaseModel where RecordProvider == MapProvider {
    func map(forName name: String) async -> MapModel? {
        await fetchRecords()
        let map = record(forID: name)
        return map
    }
}
