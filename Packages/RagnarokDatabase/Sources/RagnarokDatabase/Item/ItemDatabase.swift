//
//  ItemDatabase.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2024/3/11.
//

import Foundation
import RapidYAML

final public class ItemDatabase: Sendable {
    public let baseURL: URL
    public let mode: DatabaseMode

    public init(baseURL: URL, mode: DatabaseMode) {
        self.baseURL = baseURL
        self.mode = mode
    }

    public func items() async throws -> [Item] {
        async let usableItems = usableItems()
        async let equipItems = equipItems()
        async let etcItems = etcItems()

        let items = try await usableItems + equipItems + etcItems
        return items
    }

    public func usableItems() async throws -> [Item] {
        metric.beginMeasuring("Load usable items")

        let decoder = YAMLDecoder()

        let url = baseURL.appending(path: "db/\(mode.path)/item_db_usable.yml")
        let data = try Data(contentsOf: url)
        let usableItems = try decoder.decode(ListNode<Item>.self, from: data).body

        metric.endMeasuring("Load usable items")

        return usableItems
    }

    public func equipItems() async throws -> [Item] {
        metric.beginMeasuring("Load equip items")

        let decoder = YAMLDecoder()

        let url = baseURL.appending(path: "db/\(mode.path)/item_db_equip.yml")
        let data = try Data(contentsOf: url)
        let equipItems = try decoder.decode(ListNode<Item>.self, from: data).body

        metric.endMeasuring("Load equip items")

        return equipItems
    }

    public func etcItems() async throws -> [Item] {
        metric.beginMeasuring("Load etc items")

        let decoder = YAMLDecoder()

        let url = baseURL.appending(path: "db/\(mode.path)/item_db_etc.yml")
        let data = try Data(contentsOf: url)
        let etcItems = try decoder.decode(ListNode<Item>.self, from: data).body

        metric.endMeasuring("Load etc items")

        return etcItems
    }
}
