//
//  Database.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/1/12.
//  Copyright © 2021 Leon & Vane. All rights reserved.
//

class Database {

    static let shared = Database()

    func fetchItems(with predicate: (Records.Item) -> Bool = { _ in true }, renewal: Bool = true) -> [Records.Item] {
        return []
    }

    func fetchMonsters(with predicate: (Records.Monster) -> Bool = { _ in true }, renewal: Bool = true) -> [Records.Monster] {
        return []
    }
}
