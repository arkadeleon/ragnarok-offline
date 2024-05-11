//
//  MonsterSummonDatabaseView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/9.
//

import SwiftUI

struct MonsterSummonDatabaseView: View {
    @ObservedObject var database: ObservableDatabase<MonsterSummonProvider>

    var body: some View {
        DatabaseView(database: database) { monsterSummons in
            ResponsiveView {
                List(monsterSummons) { monsterSummon in
                    NavigationLink(monsterSummon.monsterSummon.group, value: monsterSummon)
                }
                .listStyle(.plain)
            } regular: {
                Table(monsterSummons) {
                    TableColumn("Group") { monsterSummon in
                        HStack {
                            Text(monsterSummon.monsterSummon.group)
                            NavigationLink(value: monsterSummon) {
                                Image(systemName: "info.circle")
                            }
                        }
                    }
                    TableColumn("Default", value: \.monsterSummon.default)
                }
            }
        }
        .navigationTitle("Monster Summon Database")
    }
}

#Preview {
    MonsterSummonDatabaseView(database: .init(mode: .renewal, recordProvider: .monsterSummon))
}
