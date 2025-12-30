//
//  ItemRandomOptionNameTable.swift
//  RagnarokLocalization
//
//  Created by Leon Li on 2025/8/5.
//

import Foundation

final public class ItemRandomOptionNameTable {
    let itemRandomOptionNamesByID: [Int : String]

    public init(locale: Locale = .current) {
        guard let url = Bundle.module.url(forResource: "ItemRandomOptionName", withExtension: "json", locale: locale) else {
            self.itemRandomOptionNamesByID = [:]
            return
        }

        do {
            let decoder = JSONDecoder()
            let data = try Data(contentsOf: url)
            self.itemRandomOptionNamesByID = try decoder.decode([Int : String].self, from: data)
        } catch {
            self.itemRandomOptionNamesByID = [:]
        }
    }

    public func localizedItemRandomOptionName(forID itemRandomOptionID: Int) -> String? {
        itemRandomOptionNamesByID[itemRandomOptionID]
    }
}
