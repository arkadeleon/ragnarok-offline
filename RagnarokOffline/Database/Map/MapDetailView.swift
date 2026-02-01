//
//  MapDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/4.
//

import SwiftUI

struct MapDetailView: View {
    var map: MapModel

    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(DatabaseModel.self) private var database

    @State private var spawningMonsters: [SpawningMonster] = []
    @State private var mapForMapViewer: MapModel?

    var body: some View {
        DatabaseRecordDetailView {
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
            .stretchy()

            if !spawningMonsters.isEmpty {
                DatabaseRecordSectionView("Monsters") {
                    LazyVGrid(columns: [imageGridItem(sizeClass)], alignment: .leading, spacing: vSpacing(sizeClass)) {
                        ForEach(spawningMonsters) { spawningMonster in
                            NavigationLink(value: spawningMonster.monster) {
                                ImageGridCell(
                                    title: spawningMonster.monster.displayName,
                                    subtitle: "(\(spawningMonster.spawn.amount)x)"
                                ) {
                                    MonsterImageView(monster: spawningMonster.monster)
                                }
                            }
                        }
                    }
                    .padding(.vertical, vSpacing(sizeClass))
                }
            }
        }
        .navigationTitle(map.displayName)
        .toolbar {
            Button("View") {
                mapForMapViewer = map
            }
        }
        .sheet(item: $mapForMapViewer) { map in
            NavigationStack {
                MapViewer(mapName: map.name) {
                    mapForMapViewer = nil
                }
            }
            .presentationSizing(.page)
        }
        .task {
            await map.fetchImage()
        }
        .task {
            spawningMonsters = await database.spawningMonsters(forMapName: map.name)
        }
    }
}
