//
//  MapViewer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/6/9.
//

import FileFormats
import RealityKit
import RORendering
import ResourceManagement
import SGLMath
import SwiftUI

struct MapViewer: View {
    var mapName: String
    var onDone: () -> Void

    var body: some View {
        AsyncContentView {
            try await loadEntity()
        } content: { entity in
            ModelViewer(entity: entity)
        }
        .navigationTitle(mapName)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done", action: onDone)
            }
        }
    }

    private func loadEntity() async throws -> Entity {
        let worldPath = ResourcePath(components: ["data", mapName])
        let world = try await ResourceManager.shared.world(at: worldPath)

        let worldEntity = try await Entity.worldEntity(world: world, resourceManager: .shared)

        let translation = simd_float4x4(translation: [-Float(world.gat.width / 2), 0, -Float(world.gat.height / 2)])
        let rotation = simd_float4x4(rotationX: radians(-90))
        let scaleFactor = 2 / Float(max(world.gat.width, world.gat.height))
        let scale = simd_float4x4(scale: [scaleFactor, scaleFactor, scaleFactor])
        worldEntity.transform.matrix = scale * rotation * translation

        let entity = Entity()
        entity.addChild(worldEntity)

        return entity
    }

    init(mapName: String, onDone: @escaping () -> Void) {
        self.mapName = mapName
        self.onDone = onDone
    }
}
