//
//  ArmorListView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaCommon

struct ArmorListView: View {
    @EnvironmentObject var database: Database

    private var armors: [RAItem] {
        database.allItems.filter({ $0.type == .armor })
    }

    var body: some View {
        List(armors, id: \.itemID) { armor in
            Text("\(armor.name) [\(armor.slots)]")
        }
        .navigationTitle("Armors")
        .task {
            await database.fetchItems()
        }
    }
}
