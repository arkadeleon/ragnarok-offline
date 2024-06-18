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
                List(monsterSummons) { monsterSummon in
                    NavigationLink(value: monsterSummon) {
                        HStack {
                            Text(monsterSummon.monsterSummon.group)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            Text(monsterSummon.monsterSummon.default)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.secondary)
                            Text("\(monsterSummon.monsterSummon.summon.count) monsters")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Monster Summon Database")
    }
}

#Preview {
    MonsterSummonDatabaseView()
}
