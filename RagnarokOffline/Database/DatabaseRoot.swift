//
//  DatabaseRoot.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/4.
//

import RODatabase
import SwiftUI

struct DatabaseRoot<RecordProvider, Empty>: ViewModifier where RecordProvider: DatabaseRecordProvider, Empty: View {
    @Binding var database: ObservableDatabase<RecordProvider>
    @ViewBuilder var empty: () -> Empty

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var searchFieldPlacement: SearchFieldPlacement {
        #if os(macOS)
        .automatic
        #else
        if horizontalSizeClass == .compact {
            .navigationBarDrawer(displayMode: .always)
        } else {
            .automatic
        }
        #endif
    }

    func body(content: Content) -> some View {
        content
            .background(.background)
            .overlay {
                if database.loadStatus == .loading {
                    ProgressView()
                }
            }
            .overlay {
                if database.loadStatus == .loaded && database.filteredRecords.isEmpty {
                    empty()
                }
            }
            .navigationDestination(for: Item.self) { item in
                ItemInfoView(mode: database.mode, item: item)
            }
            .navigationDestination(for: Job.self) { job in
                JobInfoView(mode: database.mode, job: job)
            }
            .navigationDestination(for: Map.self) { map in
                MapInfoView(mode: database.mode, map: map)
            }
            .navigationDestination(for: ObservableMonster.self) { monster in
                MonsterInfoView(monster: monster)
            }
            .navigationDestination(for: ObservableMonsterSummon.self) { monsterSummon in
                MonsterSummonInfoView(monsterSummon: monsterSummon)
            }
            .navigationDestination(for: ObservablePet.self) { pet in
                PetInfoView(pet: pet)
            }
            .navigationDestination(for: Skill.self) { skill in
                SkillInfoView(mode: database.mode, skill: skill)
            }
            .navigationDestination(for: StatusChange.self) { statusChange in
                StatusChangeInfoView(mode: database.mode, statusChange: statusChange)
            }
            .searchable(text: $database.searchText, placement: searchFieldPlacement)
            .onSubmit(of: .search) {
                Task {
                    await database.filterRecords()
                }
            }
            .onChange(of: database.searchText) {
                Task {
                    await database.filterRecords()
                }
            }
            .task {
                await database.fetchRecords()
            }
    }
}

extension View {
    func databaseRoot<RecordProvider, Empty>(
        _ database: Binding<ObservableDatabase<RecordProvider>>,
        @ViewBuilder empty: @escaping () -> Empty
    ) -> some View where RecordProvider: DatabaseRecordProvider, Empty: View {
        modifier(DatabaseRoot(database: database, empty: empty))
    }
}
