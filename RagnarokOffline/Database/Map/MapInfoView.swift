//
//  MapInfoView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/4.
//

import SwiftUI

struct MapInfoView: View {
    var map: ObservableMap

    var body: some View {
        ScrollView {
            LazyVStack(pinnedViews: .sectionHeaders) {
                ZStack {
                    if let mapImage = map.image {
                        Image(mapImage, scale: 1, label: Text(map.displayName))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image(systemName: "map")
                            .font(.system(size: 100, weight: .thin))
                            .foregroundStyle(Color.secondary)
                    }
                }
                .frame(height: 200)

                if !map.spawnMonsters.isEmpty {
                    DatabaseRecordSectionView("Spawn Monsters", spacing: 30) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 20)], alignment: .leading, spacing: 30) {
                            ForEach(map.spawnMonsters, id: \.monster.id) { spawnMonster in
                                NavigationLink(value: spawnMonster.monster) {
                                    MonsterGridCell(monster: spawnMonster.monster, secondaryText: "(\(spawnMonster.spawn.amount)x)")
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
        .background(.background)
        .navigationTitle(map.displayName)
        .task {
            await map.fetchDetail()
        }
    }
}
