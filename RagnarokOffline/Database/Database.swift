//
//  Database.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/1/12.
//  Copyright © 2021 Leon & Vane. All rights reserved.
//

import SQLite

class Database {

    static let shared = Database()

    private let client: Connection

    init() {
        let path = Bundle.main.path(forResource: "client", ofType: "sqlite3")!
        client = try! Connection(path)
    }

    func fetchItems(with predicate: Expression<Bool>? = nil, renewal: Bool = true) -> [Records.Item] {
        let table = renewal ? Table("item_db") : Table("item_db_re")

        let query: QueryType
        if let predicate = predicate {
            query = table.filter(predicate)
        } else {
            query = table
        }

        if let results = try? client.prepare(query) {
            return results.map { Records.Item(from: $0) }
        } else {
            return []
        }
    }

    func fetchMonsters(with predicate: Expression<Bool>? = nil, renewal: Bool = true) -> [Records.Monster] {
        let table = renewal ? Table("mob_db") : Table("mob_db_re")

        let query: QueryType
        if let predicate = predicate {
            query = table.filter(predicate)
        } else {
            query = table
        }

        if let results = try? client.prepare(query) {
            return results.map { Records.Monster(from: $0) }
        } else {
            return []
        }
    }
}
