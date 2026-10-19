//
//  DatabaseSearchIndex.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/19.
//

import Foundation

struct DatabaseSearchIndex: Sendable {
    private var keys: [[String]]

    init() {
        keys = []
    }

    init<DatabaseRecords>(_ records: DatabaseRecords, keys: (DatabaseRecords.Element) -> [String]) where DatabaseRecords: Collection {
        self.keys = records.map(keys)
    }

    @concurrent
    func indices(matching searchText: String) async -> [Int] {
        keys.indices.filter { index in
            keys[index].contains { key in
                key.localizedStandardContains(searchText)
            }
        }
    }
}
