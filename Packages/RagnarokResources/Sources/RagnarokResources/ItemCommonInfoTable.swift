//
//  ItemCommonInfoTable.swift
//  RagnarokResources
//
//  Created by Leon Li on 2026/5/20.
//

import Foundation

struct ItemCommonInfo: Decodable {
    var unidentifiedItemResourceName: String?
    var identifiedItemResourceName: String?
    var slotCount: Int?
}

final public class ItemCommonInfoTable: Resource {
    let itemCommonInfosByID: [Int : ItemCommonInfo]

    init(itemCommonInfosByID: [Int : ItemCommonInfo] = [:]) {
        self.itemCommonInfosByID = itemCommonInfosByID
    }

    public func identifiedItemResourceName(forItemID itemID: Int) -> String? {
        itemCommonInfosByID[itemID]?.identifiedItemResourceName
    }
}

extension ResourceManager {
    public func itemCommonInfoTable() async -> ItemCommonInfoTable {
        await cache.resource(forIdentifier: "ItemCommonInfoTable") {
            guard let url = Bundle.module.url(forResource: "ItemCommonInfo", withExtension: "json") else {
                return ItemCommonInfoTable()
            }

            do {
                let decoder = JSONDecoder()
                let data = try Data(contentsOf: url)
                let itemCommonInfosByID = try decoder.decode([Int : ItemCommonInfo].self, from: data)
                return ItemCommonInfoTable(itemCommonInfosByID: itemCommonInfosByID)
            } catch {
                return ItemCommonInfoTable()
            }
        }
    }
}
