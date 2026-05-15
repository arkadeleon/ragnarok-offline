//
//  MapViewer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/6/9.
//

import Metal
import RagnarokRenderAssets
import RagnarokResources
import SwiftUI

struct MapViewer: View {
    var resourceManager: ResourceManager

    private let progress = Progress()

    @Environment(DatabaseModel.self) private var database

    @State private var selectedMap: MapModel?

    var body: some View {
        ZStack {
            if let selectedMap {
                AsyncContentView {
                    try await loadRenderer(for: selectedMap.name)
                } content: { renderer in
                    MetalViewContainer(renderer: renderer)
                } placeholder: {
                    ProgressView(progress)
                        .progressViewStyle(.circular)
                }
                .id(selectedMap.name)
            }
        }
        .navigationTitle("Map Viewer")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                MapPicker(selection: $selectedMap)
            }
        }
        .task {
            await database.fetchMaps()

            if selectedMap == nil {
                selectedMap = database.maps.first
            }
        }
    }

    private func loadRenderer(for mapName: String) async throws -> RSWFilePreviewRenderer {
        let world = try await resourceManager.world(mapName: "\(mapName).rsw")
        let worldAssetLoader = WorldAssetLoader()
        let worldAsset = try await worldAssetLoader.load(
            gat: world.gat,
            gnd: world.gnd,
            rsw: world.rsw,
            resourceManager: resourceManager,
            progress: progress
        )

        let device = MTLCreateSystemDefaultDevice()!
        let renderer = try RSWFilePreviewRenderer(device: device, worldAsset: worldAsset)
        return renderer
    }
}
