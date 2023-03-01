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

    func fetchItems() async {
        if !allItems.isEmpty {
            return
        }

        let database = RAItemDatabase()
        allItems = await database.fetchAllItems()
    }

    func fetchMonsters() async {
        if !allMonsters.isEmpty {
            return
        }

        let database = RAMonsterDatabase()
        allMonsters = await database.fetchAllMonsters()
    }
}
