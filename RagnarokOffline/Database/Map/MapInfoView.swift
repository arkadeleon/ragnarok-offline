//
//  MapInfoView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/4.
//

import SwiftUI

struct MapInfoView: View {
    var map: ObservableMap

    @Environment(\.horizontalSizeClass) private var sizeClass

    @State private var isMapViewerPresented = false

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
                    DatabaseRecordSectionView("Spawn Monsters") {
                        LazyVGrid(columns: [imageGridItem(sizeClass)], alignment: .leading, spacing: vSpacing(sizeClass)) {
                            ForEach(map.spawnMonsters) { spawnMonster in
                                NavigationLink(value: spawnMonster.monster) {
                                    MonsterGridCell(monster: spawnMonster.monster, secondaryText: "(\(spawnMonster.spawn.amount)x)")
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, vSpacing(sizeClass))
                    }
                }
            }
        }
        .background(.background)
        .navigationTitle(map.displayName)
        .toolbar {
            Button("View") {
                isMapViewerPresented.toggle()
            }
        }
        .sheet(isPresented: $isMapViewerPresented) {
            NavigationStack {
                MapViewer(mapName: map.name) {
                    isMapViewerPresented.toggle()
                }
            }
        }
        .task {
            await map.fetchDetail()
        }
    }
}
