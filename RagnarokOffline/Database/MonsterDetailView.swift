//
//  MonsterDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/3/1.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaCommon

struct MonsterDetailView: View {
    @EnvironmentObject var database: Database

    let monster: RAMonster

    private var drops: [(item: RAItem, rate: Int)] {
        return monster.drops?.compactMap { drop in
            if let item = database.item(for: drop.item) {
                return (item, drop.rate)
            } else {
                return nil
            }
        } ?? []
    }

    var body: some View {
        List {
            ForEach(monster.attributes, id: \.name) { attribute in
                HStack {
                    Text(attribute.name)
                    Spacer()
                    Text(attribute.value)
                        .foregroundColor(.secondary)
                }
            }

            Section("Drops") {
                ForEach(drops, id: \.item.itemID) { drop in
                    NavigationLink {
                        ItemDetailView(item: drop.item)
                    } label: {
                        HStack {
                            Text(drop.item.name)
                            Text(String(format: "(%.2f%%)", Float(drop.rate) / 100))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(monster.name)
        .task {
            await database.fetchItems()
        }
    }
}

struct MonsterDetailView_Previews: PreviewProvider {
    static let previews = Previews()

    struct Previews: View {
        @StateObject private var database = Database()
        @State private var monster = RAMonster()

        var body: some View {
            MonsterDetailView(monster: monster)
                .environmentObject(database)
                .task {
                    await database.fetchMonsters()
                    monster = database.monsters[1]
                }
        }
    }
}
