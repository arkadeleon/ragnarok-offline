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

    @Environment(AppModel.self) private var appModel

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

            if !map.spawningMonsters.isEmpty {
                DatabaseRecordSectionView("Monsters") {
                    LazyVGrid(columns: [imageGridItem(sizeClass)], alignment: .leading, spacing: vSpacing(sizeClass)) {
                        ForEach(map.spawningMonsters) { spawningMonster in
                            NavigationLink(value: spawningMonster.monster) {
                                MonsterGridCell(monster: spawningMonster.monster, secondaryText: "(\(spawningMonster.spawn.amount)x)")
                            }
                            .buttonStyle(.plain)
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
            await map.fetchDetail(monsterDatabase: appModel.monsterDatabase)
        }
    }
}
