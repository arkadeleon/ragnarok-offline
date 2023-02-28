//
//  WeaponListView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import rAthenaCommon
import SwiftUI

struct WeaponListView: View {
    @State private var weapons: [RAItem] = []

    var body: some View {
        List(weapons, id: \.itemID) { weapon in
            Text("\(weapon.name) [\(weapon.slots)]")
        }
        .navigationTitle("Weapons")
        .task {
            let database = RAItemDatabase()
            weapons = await database.fetchAllItems().filter({ $0.type == .weapon })
        }
    }
}
