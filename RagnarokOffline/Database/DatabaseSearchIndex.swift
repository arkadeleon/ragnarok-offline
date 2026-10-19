//
//  DatabaseSearchIndex.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/19.
//

import Foundation

struct DatabaseSearchIndex: Sendable {
    private struct Entry: Sendable {
        var id: Int?
        var foldedKeys: [String]

        init(keys: [String]) {
            id = nil
            foldedKeys = []

            for key in keys {
                if key.hasPrefix("#") {
                    id = Int(key.dropFirst())
                } else {
                    foldedKeys.append(key.folded())
                }
            }
        }
    }

    private var entries: [DatabaseSearchIndex.Entry]

    init() {
        entries = []
    }

    /// A key that starts with `#`, such as `#1002`, is an ID. It matches only when the search text is the
    /// whole number, such as `1002`. A record that matches by ID comes first in the search results.
    init<DatabaseRecords>(_ records: DatabaseRecords, keys: (DatabaseRecords.Element) -> [String]) where DatabaseRecords: Collection {
        entries = records.map { record in
            DatabaseSearchIndex.Entry(keys: keys(record))
        }
    }

    @concurrent
    func indices(matching searchText: String) async -> [Int] {
        let id = Int(searchText)
        let foldedSearchText = searchText.folded()

        var idMatches: [Int] = []
        var keyMatches: [Int] = []

        for (index, entry) in entries.enumerated() {
            if let id, entry.id == id {
                idMatches.append(index)
            } else if entry.foldedKeys.contains(where: { $0.range(of: foldedSearchText, options: .literal) != nil }) {
                keyMatches.append(index)
            }
        }

        return idMatches + keyMatches
    }
}

extension String {
    fileprivate func folded() -> String {
        folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: .current)
    }
}
