//
//  ItemInfoTable.swift
//  ResourceManagement
//
//  Created by Leon Li on 2024/5/28.
//

import Foundation

struct ItemInfo: Decodable {
    var unidentifiedItemName: String?
    var unidentifiedItemDescription: String?
    var identifiedItemName: String?
    var identifiedItemDescription: String?
}

final public class ItemInfoTable: LocalizedResource {
    let itemInfosByID: [Int : ItemInfo]

    init() {
        self.itemInfosByID = [:]
    }

    init(contentsOf url: URL) throws {
        let decoder = JSONDecoder()
        let data = try Data(contentsOf: url)
        self.itemInfosByID = try decoder.decode([Int : ItemInfo].self, from: data)
    }

    public func localizedIdentifiedItemName(forItemID itemID: Int) -> String? {
        itemInfosByID[itemID]?.identifiedItemName
    }

    public func localizedIdentifiedItemDescription(forItemID itemID: Int) -> String? {
        itemInfosByID[itemID]?.identifiedItemDescription
    }
}

extension ResourceManager {
    public func itemInfoTable(for locale: Locale) async -> ItemInfoTable {
        let localeIdentifier = locale.identifier(.bcp47)
        let resourceIdentifier = "ItemInfoTable-\(localeIdentifier)"

        if let phase = resources[resourceIdentifier] {
            return await phase.resource as! ItemInfoTable
        }

        let task = ResourceTask {
            if let url = Bundle.module.url(forResource: "ItemInfo", withExtension: "json", locale: locale),
               let itemInfoTable = try? ItemInfoTable(contentsOf: url) {
                return itemInfoTable
            } else {
                return ItemInfoTable()
            }
        }

        resources[resourceIdentifier] = .inProgress(task)

        let itemInfoTable = await task.value as! ItemInfoTable

        resources[resourceIdentifier] = .loaded(itemInfoTable)

        return itemInfoTable
    }
}
