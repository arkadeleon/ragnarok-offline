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
                    NavigationLink(monsterSummon.group, value: monsterSummon)
                }
                .listStyle(.plain)
            } regular: {
                List(monsterSummons) { monsterSummon in
                    NavigationLink(value: monsterSummon) {
                        HStack {
                            Text(monsterSummon.group)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            Text(monsterSummon.default)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.secondary)
                            Text("\(monsterSummon.summon.count) monsters")
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .listStyle(.plain)
            }
        } empty: {
            ContentUnavailableView("No Monster Summons", systemImage: "pawprint.fill")
        }
        .navigationTitle("Monster Summon Database")
    }
}

#Preview {
    MonsterSummonDatabaseView()
}
