//
//  MonsterListView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct MonsterListView: View {
    @EnvironmentObject var database: Database

    var body: some View {
        List(database.allMonsters, id: \.monsterID) { monster in
            Text(monster.name)
        }
        .navigationTitle("Cards")
        .task {
            await database.fetchMonsters()
        }
    }
}
