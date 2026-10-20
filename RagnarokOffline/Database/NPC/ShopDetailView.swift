//
//  ShopDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/10/20.
//

import SwiftUI

struct ShopDetailView: View {
    var shop: ShopModel

    @Environment(DatabaseModel.self) private var database

    @State private var shopItems: [ShopItem] = []

    var body: some View {
        DatabaseRecordDetailView {
            ZStack {
                if let animatedImage = shop.npc.animatedImage {
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
                NavigationLink(value: shop.map) {
                    VStack(spacing: 8) {
                        MapLocationView(map: shop.map, locations: [MapLocation(x: shop.npc.x, y: shop.npc.y)])

                        VStack(spacing: 4) {
                            Text(shop.map.displayName)
                                .foregroundStyle(Color.primary)
                            PositionBadge(x: shop.npc.x, y: shop.npc.y)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            } header: {
                Text("Map", tableName: "Database")
            }

            if !shopItems.isEmpty {
                DatabaseRecordSectionView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)], alignment: .leading, spacing: 20) {
                        ForEach(shopItems) { shopItem in
                            NavigationLink(value: shopItem.item) {
                                ItemCell(item: shopItem.item) {
                                    PriceBadge(price: shopItem.price, shopType: shop.shopNPC.shopType)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Items", tableName: "Database")
                }
            }
        }
        .navigationTitle(shop.npc.displayName)
        .task {
            await shop.npc.fetchAnimatedImage()
        }
        .task {
            shopItems = await database.shopItems(for: shop.shopNPC)
        }
    }
}
