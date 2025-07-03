//
//  MonsterSummonDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/9.
//

import SwiftUI
import RODatabase

struct MonsterSummonDatabaseView: View {
    @Environment(AppModel.self) private var appModel

    private var database: ObservableDatabase<MonsterSummonProvider> {
        appModel.monsterSummonDatabase
    }

    var body: some View {
        AdaptiveView {
            List(database.filteredRecords) { monsterSummon in
                NavigationLink(monsterSummon.displayName, value: monsterSummon)
            }
            .listStyle(.plain)
        } regular: {
            List(database.filteredRecords) { monsterSummon in
                NavigationLink(value: monsterSummon) {
                    HStack {
                        Text(monsterSummon.displayName)
                            .frame(minWidth: 160, maxWidth: .infinity, alignment: .leading)
                        Text(monsterSummon.default)
                            .frame(minWidth: 120, maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color.secondary)
                        Text("\(monsterSummon.summon.count) monsters")
                            .frame(minWidth: 120, maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Monster Summon Database")
        .databaseRoot(database) {
            ContentUnavailableView("No Results", systemImage: "pawprint.fill")
        }
    }
}

#Preview("Pre-Renewal Monster Summon Database") {
    @Previewable @State var appModel = AppModel()
    appModel.monsterSummonDatabase = ObservableDatabase(mode: .prerenewal, recordProvider: .monsterSummon)

    return MonsterSummonDatabaseView()
        .environment(appModel)
}

#Preview("Renewal Monster Summon Database") {
    @Previewable @State var appModel = AppModel()
    appModel.monsterSummonDatabase = ObservableDatabase(mode: .prerenewal, recordProvider: .monsterSummon)

    return MonsterSummonDatabaseView()
        .environment(appModel)
}
