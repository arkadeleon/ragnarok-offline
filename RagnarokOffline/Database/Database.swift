//
//  Database.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2021/1/12.
//  Copyright © 2021 Leon & Vane. All rights reserved.
//

import Foundation
import rAthenaCommon

@MainActor
class Database: ObservableObject {
    @Published var allItems: [RAItem] = []
    @Published var allMonsters: [RAMonster] = []

    private var allItemsWithNames: [String: RAItem] = [:]
    private var allMonstersWithNames: [String: RAMonster] = [:]

    func fetchItems() async {
        if !allItems.isEmpty {
            return
        }

        let database = RAItemDatabase()
        allItems = await database.fetchItems(in: .renewal)
        allItemsWithNames = Dictionary(uniqueKeysWithValues: allItems.map({ ($0.aegisName, $0) }))
    }

    func fetchMonsters() async {
        if !allMonsters.isEmpty {
            return
        }

        let database = RAMonsterDatabase()
        allMonsters = await database.fetchMonsters(in: .renewal)
        allMonstersWithNames = Dictionary(uniqueKeysWithValues: allMonsters.map({ ($0.aegisName, $0) }))
    }

    func item(for aegisName: String) -> RAItem? {
        return allItemsWithNames[aegisName];
    }
}
