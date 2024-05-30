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
        DatabaseView(database: $database) { monsterSummons in
            ResponsiveView {
                List(monsterSummons) { monsterSummon in
                    NavigationLink(monsterSummon.monsterSummon.group, value: monsterSummon)
                }
                .listStyle(.plain)
            } regular: {
                Table(monsterSummons) {
                    TableColumn("Group") { monsterSummon in
                        NavigationLink(value: monsterSummon) {
                            Text(monsterSummon.monsterSummon.group)
                        }
                    }
                    TableColumn("Default", value: \.monsterSummon.default)
                    TableColumn("Summon") { monsterSummon in
                        Text("\(monsterSummon.monsterSummon.summon.count) monsters")
                    }
                }
            }
        }
        .navigationTitle("Monster Summon Database")
    }
}

#Preview {
    MonsterSummonDatabaseView()
}
