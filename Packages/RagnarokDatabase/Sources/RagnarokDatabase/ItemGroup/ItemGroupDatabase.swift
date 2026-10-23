//
//  ItemGroupDatabase.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2026/10/23.
//

import Foundation
import RapidYAML

final public class ItemGroupDatabase: Sendable {
    public let baseURL: URL
    public let mode: DatabaseMode

    public init(baseURL: URL, mode: DatabaseMode) {
        self.baseURL = baseURL
        self.mode = mode
    }

    public func itemGroups() async throws -> [ItemGroup] {
        metric.beginMeasuring("Load item groups")

        let decoder = YAMLDecoder()

        let url = baseURL.appending(path: "db/\(mode.path)/item_group_db.yml")
        let data = try Data(contentsOf: url)
        let itemGroups = try decoder.decode(ListNode<ItemGroup>.self, from: data).body

        metric.endMeasuring("Load item groups")

        return itemGroups
    }
}
