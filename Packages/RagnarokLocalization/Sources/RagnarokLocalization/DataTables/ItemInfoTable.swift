//
//  ItemInfoTable.swift
//  RagnarokLocalization
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

final public class ItemInfoTable {
    let itemInfosByID: [Int : ItemInfo]

    public init(locale: Locale = .current) {
        guard let url = Bundle.module.url(forResource: "ItemInfo", withExtension: "json", locale: locale) else {
            self.itemInfosByID = [:]
            return
        }

        do {
            let decoder = JSONDecoder()
            let data = try Data(contentsOf: url)
            self.itemInfosByID = try decoder.decode([Int : ItemInfo].self, from: data)
        } catch {
            self.itemInfosByID = [:]
        }
    }

    public func localizedIdentifiedItemName(forItemID itemID: Int) -> String? {
        itemInfosByID[itemID]?.identifiedItemName
    }

    public func localizedIdentifiedItemDescription(forItemID itemID: Int) -> String? {
        itemInfosByID[itemID]?.identifiedItemDescription
    }
}
