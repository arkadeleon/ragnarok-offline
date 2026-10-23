//
//  MonstersDroppingItemView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/23.
//

import SwiftUI

struct MonstersDroppingItem: Hashable {
    var item: ItemModel
}

struct MonstersDroppingItemView: View {
    var monstersDroppingItem: MonstersDroppingItem

    @Environment(DatabaseModel.self) private var database

    @State private var dropSources: [ItemModel.DropSource] = []

    var body: some View {
        ImageGrid(dropSources) { dropSource in
            NavigationLink(value: dropSource.monster) {
                ImageGridCell(title: dropSource.monster.displayName, badges: dropSource.badges) {
                    MonsterImageView(monster: dropSource.monster)
                }
            }
        }
        .background(.background)
        .navigationTitle(Text("Dropped By", tableName: "Database"))
        .task {
            dropSources = await database.dropSources(forItemAegisName: monstersDroppingItem.item.aegisName)
        }
    }
}
