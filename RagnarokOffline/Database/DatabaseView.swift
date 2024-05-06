//
//  DatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/6.
//

import SwiftUI

struct DatabaseView: View {
    @StateObject private var itemDatabase = ObservableItemDatabase(database: .renewal)
    @StateObject private var monsterDatabase = ObservableMonsterDatabase(database: .renewal)
    @StateObject private var jobDatabase = ObservableJobDatabase(database: .renewal)
    @StateObject private var skillDatabase = ObservableSkillDatabase(database: .renewal)
    @StateObject private var mapDatabase = ObservableMapDatabase(database: .renewal)

    var body: some View {
        List {
            NavigationLink(value: MenuItem.itemDatabase) {
                Label("Item Database", systemImage: "leaf")
            }

            NavigationLink(value: MenuItem.monsterDatabase) {
                Label("Monster Database", systemImage: "pawprint")
            }

            NavigationLink(value: MenuItem.jobDatabase) {
                Label("Job Database", systemImage: "person")
            }

            NavigationLink(value: MenuItem.skillDatabase) {
                Label("Skill Database", systemImage: "arrow.up.heart")
            }

            NavigationLink(value: MenuItem.mapDatabase) {
                Label("Map Database", systemImage: "map")
            }
        }
        .navigationDestination(for: MenuItem.self) { item in
            switch item {
            case .itemDatabase:
                ItemDatabaseView(itemDatabase: itemDatabase)
            case .monsterDatabase:
                MonsterDatabaseView(monsterDatabase: monsterDatabase)
            case .jobDatabase:
                JobDatabaseView(jobDatabase: jobDatabase)
            case .skillDatabase:
                SkillDatabaseView(skillDatabase: skillDatabase)
            case .mapDatabase:
                MapDatabaseView(mapDatabase: mapDatabase)
            default:
                EmptyView()
            }
        }
        .navigationTitle("Database")
    }
}

#Preview {
    DatabaseView()
}
