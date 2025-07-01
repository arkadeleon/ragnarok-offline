//
//  DatabaseRoot.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/4.
//

import RODatabase
import SwiftUI

struct DatabaseRoot<RecordProvider, Empty>: ViewModifier where RecordProvider: DatabaseRecordProvider, Empty: View {
    @Bindable var database: ObservableDatabase<RecordProvider>
    @ViewBuilder var empty: () -> Empty

    @Environment(\.horizontalSizeClass) private var sizeClass

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
            .navigationDestination(for: ObservableItem.self) { item in
                ItemDetailView(item: item)
            }
            .navigationDestination(for: ObservableJob.self) { job in
                JobDetailView(job: job)
            }
            .navigationDestination(for: ObservableMap.self) { map in
                MapDetailView(map: map)
            }
            .navigationDestination(for: ObservableMonster.self) { monster in
                MonsterDetailView(monster: monster)
            }
            .navigationDestination(for: ObservableMonsterSummon.self) { monsterSummon in
                MonsterSummonDetailView(monsterSummon: monsterSummon)
            }
            .navigationDestination(for: ObservablePet.self) { pet in
                PetDetailView(pet: pet)
            }
            .navigationDestination(for: ObservableSkill.self) { skill in
                SkillDetailView(skill: skill)
            }
            .navigationDestination(for: ObservableStatusChange.self) { statusChange in
                StatusChangeDetailView(statusChange: statusChange)
            }
            .searchable(text: $database.searchText, placement: searchFieldPlacement(sizeClass))
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
        _ database: ObservableDatabase<RecordProvider>,
        @ViewBuilder empty: @escaping () -> Empty
    ) -> some View where RecordProvider: DatabaseRecordProvider, Empty: View {
        modifier(DatabaseRoot(database: database, empty: empty))
    }
}
