//
//  ItemComboDatabase.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2026/10/24.
//

import Foundation
import RapidYAML

final public class ItemComboDatabase: Sendable {
    public let baseURL: URL
    public let mode: DatabaseMode

    public init(baseURL: URL, mode: DatabaseMode) {
        self.baseURL = baseURL
        self.mode = mode
    }

    public func itemCombos() async throws -> [ItemCombo] {
        metric.beginMeasuring("Load item combos")

        let decoder = YAMLDecoder()

        let url = baseURL.appending(path: "db/\(mode.path)/item_combos.yml")
        let data = try Data(contentsOf: url)
        let itemCombos = try decoder.decode(ListNode<ItemCombo>.self, from: data).body

        metric.endMeasuring("Load item combos")

        return itemCombos
    }
}
