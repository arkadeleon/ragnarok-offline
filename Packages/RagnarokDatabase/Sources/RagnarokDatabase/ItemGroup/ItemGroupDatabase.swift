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

    /// The IDs of the items in `items` whose scripts call `getgroupitem(IG_<name>)`, keyed by the uppercased
    /// group name. For example, `getgroupitem(IG_BlueBox);` adds the item to `BLUEBOX`.
    public func sourceItemIDs(in items: [Item]) async -> [String : [Item.ID]] {
        metric.beginMeasuring("Find item group source items")

        var sourceItemIDs: [String : [Item.ID]] = [:]

        for item in items {
            guard let script = item.script, script.contains("getgroupitem(IG_") else {
                continue
            }
            for match in script.matches(of: /getgroupitem\(IG_([A-Za-z0-9_]+)/) {
                let groupName = String(match.1).uppercased()
                if sourceItemIDs[groupName]?.last != item.id {
                    sourceItemIDs[groupName, default: []].append(item.id)
                }
            }
        }

        metric.endMeasuring("Find item group source items")

        return sourceItemIDs
    }
}
