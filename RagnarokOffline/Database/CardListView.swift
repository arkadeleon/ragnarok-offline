//
//  CardListView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaCommon

struct CardListView: View {
    @EnvironmentObject var database: Database

    private var cards: [RAItem] {
        database.allItems.filter({ $0.type == .card })
    }

    var body: some View {
        List(cards, id: \.itemID) { card in
            Text(card.name)
        }
        .navigationTitle("Cards")
        .task {
            await database.fetchItems()
        }
    }
}
