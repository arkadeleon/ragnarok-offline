//
//  WeaponListView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaCommon

struct WeaponListView: View {
    @EnvironmentObject var database: Database

    private var weapons: [RAItem] {
        database.allItems.filter({ $0.type == .weapon })
    }

    var body: some View {
        List(weapons, id: \.itemID) { weapon in
            Text("\(weapon.name) [\(weapon.slots)]")
        }
        .navigationTitle("Weapons")
        .task {
            await database.fetchItems()
        }
    }
}
