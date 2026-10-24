//
//  ArrowCraftingDatabase.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2026/10/25.
//

import Foundation
import RapidYAML

final public class ArrowCraftingDatabase: Sendable {
    public let baseURL: URL
    public let mode: DatabaseMode

    public init(baseURL: URL, mode: DatabaseMode) {
        self.baseURL = baseURL
        self.mode = mode
    }

    public func arrowCraftings() async throws -> [ArrowCrafting] {
        metric.beginMeasuring("Load arrow craftings")

        let decoder = YAMLDecoder()

        let url = baseURL.appending(path: "db/create_arrow_db.yml")
        let data = try Data(contentsOf: url)
        let arrowCraftings = try decoder.decode(ListNode<ArrowCrafting>.self, from: data).body

        metric.endMeasuring("Load arrow craftings")

        return arrowCraftings
    }
}
