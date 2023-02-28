//
//  CardListView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import rAthenaCommon
import SwiftUI

struct CardListView: View {
    @State private var cards: [RAItem] = []

    var body: some View {
        List(cards, id: \.itemID) { card in
            Text(card.name)
        }
        .navigationTitle("Cards")
        .task {
            let database = RAItemDatabase()
            cards = await database.fetchAllItems().filter({ $0.type == .card })
        }
    }
}
