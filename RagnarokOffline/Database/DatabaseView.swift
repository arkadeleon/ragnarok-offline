//
//  DatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/11.
//

import SwiftUI
import RODatabase

struct DatabaseView<RecordProvider, Content>: View where RecordProvider: DatabaseRecordProvider, Content: View {
    @Binding var database: ObservableDatabase<RecordProvider>
    var content: ([RecordProvider.Record]) -> Content

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var searchFieldPlacement: SearchFieldPlacement {
        if horizontalSizeClass == .compact {
            .navigationBarDrawer(displayMode: .always)
        } else {
            .automatic
        }
    }

    var body: some View {
        content(database.filteredRecords)
            .overlay {
                if database.loadStatus == .loading {
                    ProgressView()
                }
            }
            .overlay {
                if database.loadStatus == .loaded && database.filteredRecords.isEmpty {
                    EmptyContentView("No Records")
                }
            }
            .navigationDestination(for: Item.self) { item in
                ItemInfoView(mode: database.mode, item: item)
            }
            .navigationDestination(for: JobStats.self) { jobStats in
                JobInfoView(mode: database.mode, jobStats: jobStats)
            }
            .navigationDestination(for: Map.self) { map in
                MapInfoView(mode: database.mode, map: map)
            }
            .navigationDestination(for: Monster.self) { monster in
                MonsterInfoView(mode: database.mode, monster: monster)
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
                DatabaseRecordDetailView(mode: database.mode, record: statusChange)
            }
            .searchable(text: $database.searchText, placement: searchFieldPlacement)
            .onSubmit(of: .search) {
                database.filterRecords()
            }
            .onChange(of: database.searchText) {
                database.filterRecords()
            }
            .task {
                await database.fetchRecords()
            }
    }

    init(database: Binding<ObservableDatabase<RecordProvider>>, @ViewBuilder content: @escaping ([RecordProvider.Record]) -> Content) {
        _database = database
        self.content = content
    }
}

#Preview {
    DatabaseView(database: .constant(.init(mode: .renewal, recordProvider: .monsterSummon))) { records in
        List(records) { record in
            Text(record.monsterSummon.group)
        }
    }
}
