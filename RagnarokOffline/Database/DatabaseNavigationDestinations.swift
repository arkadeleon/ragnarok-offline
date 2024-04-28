//
//  DatabaseNavigationDestinations.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/28.
//

import SwiftUI
import RODatabase

struct DatabaseNavigationDestinations: ViewModifier {
    let database: Database

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: Item.self) { item in
                ItemInfoView(database: database, item: item)
            }
            .navigationDestination(for: Monster.self) { monster in
                MonsterInfoView(database: database, monster: monster)
            }
            .navigationDestination(for: JobStats.self) { jobStats in
                JobInfoView(database: database, jobStats: jobStats)
            }
            .navigationDestination(for: Skill.self) { skill in
                SkillInfoView(database: database, skill: skill)
            }
            .navigationDestination(for: Map.self) { map in
                MapInfoView(database: database, map: map)
            }
    }
}

extension View {
    func databaseNavigationDestinations(database: Database) -> some View {
        modifier(DatabaseNavigationDestinations(database: database))
    }
}
