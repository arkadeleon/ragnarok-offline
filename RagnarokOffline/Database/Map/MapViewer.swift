//
//  MapViewer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/6/9.
//

import RagnarokFileFormats
import RagnarokResources
import RealityKit
import SGLMath
import SwiftUI

struct MapViewer: View {
    var mapName: String
    var onDone: () -> Void

    private let progress = Progress()

    var body: some View {
        AsyncContentView {
            try await loadEntity()
        } content: { entity in
            ModelViewer(entity: entity)
        } placeholder: {
            ProgressView(progress)
                .progressViewStyle(.circular)
        }
        .navigationTitle(mapName)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark", action: onDone)
            }
        }
    }

    private func loadEntity() async throws -> Entity {
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
