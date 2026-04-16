//
//  MapViewer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/6/9.
//

import RagnarokCore
import RagnarokResources
import RealityKit
import SwiftUI

struct MapViewer: View {
    private let progress = Progress()

    @Environment(DatabaseModel.self) private var database

    @State private var selectedMap: MapModel?

    var body: some View {
        ZStack {
            if let selectedMap {
                AsyncContentView {
                    try await loadEntity(for: selectedMap.name)
                } content: { entity in
                    ModelViewer(entity: entity)
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

    private func loadEntity(for mapName: String) async throws -> Entity {
        let world = try await ResourceManager.shared.world(mapName: "\(mapName).rsw")

        let worldEntity = try await Entity(from: world, resourceManager: .shared, progress: progress)

        let translation = simd_float4x4(translation: [-Float(world.gat.width / 2), 0, -Float(world.gat.height / 2)])
        let rotation = simd_float4x4(rotationX: radians(-90))
        let scaleFactor = 2 / Float(max(world.gat.width, world.gat.height))
        let scale = simd_float4x4(scale: [scaleFactor, scaleFactor, scaleFactor])
        worldEntity.transform.matrix = scale * rotation * translation

        let entity = Entity()
        entity.addChild(worldEntity)

        return entity
    }
}
