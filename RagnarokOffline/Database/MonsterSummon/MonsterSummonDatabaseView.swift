//
//  MonsterSummonDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/9.
//

import SwiftUI
import RODatabase

struct MonsterSummonDatabaseView: View {
    @State private var database = ObservableDatabase(mode: .renewal, recordProvider: .monsterSummon)

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
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        Text(monsterSummon.default)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color.secondary)
                        Text("\(monsterSummon.summon.count) monsters")
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Monster Summon Database")
        .databaseRoot($database) {
            ContentUnavailableView("No Results", systemImage: "pawprint.fill")
        }
    }
}

#Preview {
    MonsterSummonDatabaseView()
}
