//
//  ArmorListView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import rAthenaCommon
import SwiftUI

struct ArmorListView: View {
    @State private var armors: [RAItem] = []

    var body: some View {
        List(armors, id: \.itemID) { armor in
            Text("\(armor.name) [\(armor.slots)]")
        }
        .navigationTitle("Armors")
        .task {
            let database = RAItemDatabase()
            armors = await database.fetchAllItems().filter({ $0.type == .armor })
        }
    }
}
