//
//  ShopNPCListView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/25.
//

import SwiftUI

struct ShopNPCListView: View {
    var shopNPCList: ItemModel.ShopNPCList

    @Environment(DatabaseModel.self) private var database

    @State private var shopNPCs: [NPCModel] = []

    var body: some View {
        ImageGrid(shopNPCs) { shopNPC in
            NavigationLink(value: shopNPC) {
                NPCGridCell(npc: shopNPC, badges: [.map(shopNPC.map)])
            }
        }
        .background(.background)
        .navigationTitle(Text("Sold By", tableName: "Database"))
        .task {
            shopNPCs = await database.shopNPCs(for: shopNPCList.item)
        }
    }
}
