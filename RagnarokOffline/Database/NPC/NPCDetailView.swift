//
//  NPCDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/20.
//

import SwiftUI

struct NPCDetailView: View {
    var npc: NPCModel

    @Environment(DatabaseModel.self) private var database

    @State private var shopItems: [NPCModel.ShopItem] = []

    var body: some View {
        DatabaseRecordDetailView {
            ZStack {
                if let animatedImage = npc.animatedImage {
                    AnimatedImageView(animatedImage: animatedImage)
                } else {
                    Image(systemName: "person")
                        .font(.system(size: 100, weight: .thin))
                        .foregroundStyle(Color.secondary)
                }
            }
            .frame(height: 200)
            .stretchy()

            DatabaseRecordSectionView {
                NavigationLink(value: npc.map) {
                    VStack(spacing: 8) {
                        MapLocationView(map: npc.map, locations: [MapLocation(x: npc.x, y: npc.y)])

                        VStack(spacing: 4) {
                            Text(npc.map.displayName)
                                .foregroundStyle(Color.primary)
                            DatabaseBadgeView(badge: .position(x: npc.x, y: npc.y))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } header: {
                Text("Map Location", tableName: "Database")
            }

            if !shopItems.isEmpty {
                DatabaseRecordSectionView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        ForEach(shopItems) { shopItem in
                            NavigationLink(value: shopItem.item) {
                                ItemCell(item: shopItem.item, badges: shopItem.badges)
                            }
                        }
                    }
                } header: {
                    Text("Shop Items", tableName: "Database")
                }
            }

            if let code = npc.code?.trimmingCharacters(in: .whitespacesAndNewlines), !code.isEmpty {
                DatabaseRecordSectionView(text: code, monospaced: true) {
                    Text("Code", tableName: "Database")
                }
            }
        }
        .navigationTitle(npc.displayName)
        .task {
            await npc.fetchAnimatedImage()
        }
        .task {
            if let shopNPC = npc.shopNPC {
                shopItems = await database.shopItems(for: shopNPC)
            }
        }
    }
}
