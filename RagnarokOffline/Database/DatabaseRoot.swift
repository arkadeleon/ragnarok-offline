//
//  DatabaseRoot.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/4.
//

import RODatabase
import SwiftUI

struct DatabaseRoot<RecordProvider, Empty>: ViewModifier where RecordProvider: DatabaseRecordProvider, Empty: View {
    @Bindable var database: DatabaseModel<RecordProvider>
    @ViewBuilder var empty: () -> Empty

    @Environment(\.horizontalSizeClass) private var sizeClass

    @Environment(AppModel.self) private var appModel

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
            .navigationDestination(for: ItemModel.self) { item in
                ItemDetailView(item: item)
            }
            .navigationDestination(for: JobModel.self) { job in
                JobDetailView(job: job)
            }
            .navigationDestination(for: MapModel.self) { map in
                MapDetailView(map: map)
            }
            .navigationDestination(for: MonsterModel.self) { monster in
                MonsterDetailView(monster: monster)
            }
            .navigationDestination(for: MonsterSummonModel.self) { monsterSummon in
                MonsterSummonDetailView(monsterSummon: monsterSummon)
            }
            .navigationDestination(for: PetModel.self) { pet in
                PetDetailView(pet: pet)
            }
            .navigationDestination(for: SkillModel.self) { skill in
                SkillDetailView(skill: skill)
            }
            .navigationDestination(for: StatusChangeModel.self) { statusChange in
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
                await database.prefetchRecords(appModel: appModel)
            }
    }
}

extension View {
    func databaseRoot<RecordProvider, Empty>(
        _ database: DatabaseModel<RecordProvider>,
        @ViewBuilder empty: @escaping () -> Empty
    ) -> some View where RecordProvider: DatabaseRecordProvider, Empty: View {
        modifier(DatabaseRoot(database: database, empty: empty))
    }
}
