//
//  ItemProduceDatabase.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2026/10/25.
//

import Foundation

final public class ItemProduceDatabase: Sendable {
    public let baseURL: URL
    public let mode: DatabaseMode

    public init(baseURL: URL, mode: DatabaseMode) {
        self.baseURL = baseURL
        self.mode = mode
    }

    public func itemProduces() async throws -> [ItemProduce] {
        metric.beginMeasuring("Load item produces")

        let url = baseURL.appending(path: "db/\(mode.path)/produce_db.txt")
        let string = try String(contentsOf: url, encoding: .utf8)

        var itemProduces: [ItemProduce] = []

        for line in string.split(whereSeparator: \.isNewline) {
            let line = line.trimmingCharacters(in: .whitespaces)
            if line.isEmpty || line.hasPrefix("//") {
                continue
            }

            let columns = line.split(separator: ",", omittingEmptySubsequences: false).map({ $0.trimmingCharacters(in: .whitespaces) })

            if let itemProduce = ItemProduce(columns) {
                itemProduces.append(itemProduce)
            }
        }

        metric.endMeasuring("Load item produces")

        return itemProduces
    }
}
