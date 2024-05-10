//
//  DatabaseNavigationDestinations.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/28.
//

import SwiftUI
import rAthenaCommon
import RODatabase

struct DatabaseNavigationDestinations: ViewModifier {
    let mode: ServerMode

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: Item.self) { item in
                ItemInfoView(mode: mode, item: item)
            }
            .navigationDestination(for: Monster.self) { monster in
                MonsterInfoView(mode: mode, monster: monster)
            }
            .navigationDestination(for: ObservableMonsterSummon.self) { monsterSummon in
                MonsterSummonInfoView(monsterSummon: monsterSummon)
            }
            .navigationDestination(for: ObservablePet.self) { pet in
                PetInfoView(pet: pet)
            }
            .navigationDestination(for: JobStats.self) { jobStats in
                JobInfoView(mode: mode, jobStats: jobStats)
            }
            .navigationDestination(for: Skill.self) { skill in
                SkillInfoView(mode: mode, skill: skill)
            }
            .navigationDestination(for: Map.self) { map in
                MapInfoView(mode: mode, map: map)
            }
    }
}

extension View {
    func databaseNavigationDestinations(mode: ServerMode) -> some View {
        modifier(DatabaseNavigationDestinations(mode: mode))
    }
}
