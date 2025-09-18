//
//  ItemRandomOptionNameTable.swift
//  ResourceManagement
//
//  Created by Leon Li on 2025/8/5.
//

import Foundation

final public class ItemRandomOptionNameTable: Resource {
    let itemRandomOptionNamesByID: [Int : String]

    init() {
        self.itemRandomOptionNamesByID = [:]
    }

    init(contentsOf url: URL) throws {
        let decoder = JSONDecoder()
        let data = try Data(contentsOf: url)
        self.itemRandomOptionNamesByID = try decoder.decode([Int : String].self, from: data)
    }

    public func localizedItemRandomOptionName(forID itemRandomOptionID: Int) -> String? {
        itemRandomOptionNamesByID[itemRandomOptionID]
    }
}

extension ResourceManager {
    public func itemRandomOptionNameTable(for locale: Locale) async -> ItemRandomOptionNameTable {
        let localeIdentifier = locale.identifier(.bcp47)
        let taskIdentifier = "ItemRandomOptionNameTable-\(localeIdentifier)"

        if let task = tasks.withLock({ $0[taskIdentifier] }) {
            return await task.value as! ItemRandomOptionNameTable
        }

        let task = Task<any Resource, Never> {
            if let url = Bundle.module.url(forResource: "ItemRandomOptionName", withExtension: "json", locale: locale),
               let itemRandomOptionNameTable = try? ItemRandomOptionNameTable(contentsOf: url) {
                return itemRandomOptionNameTable
            } else {
                return ItemRandomOptionNameTable()
            }
        }

        tasks.withLock {
            $0[taskIdentifier] = task
        }

        return await task.value as! ItemRandomOptionNameTable
    }
}
