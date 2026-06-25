//
//  MapViewerMapRenderingView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/5/21.
//

import RagnarokRenderAssets
import RagnarokResources
import SwiftUI

#if os(visionOS)

import RagnarokCore
import RagnarokReality
import RealityKit

struct MapViewerMapRenderingView: View {
    var map: MapModel
    var resourceManager: ResourceManager

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
    }

    private func loadEntity() async throws -> Entity {
        let world = try await resourceManager.world(mapName: "\(map.name).rsw")

        let worldAssetLoader = WorldAssetLoader()
        let worldAsset = try await worldAssetLoader.load(
            world: world,
            resourceManager: resourceManager,
            progress: progress
        )

        let worldEntity = try await Entity(from: worldAsset)

        let gat = world.gat
        let translation = simd_float4x4(translation: [-Float(gat.width / 2), 0, -Float(gat.height / 2)])
        let rotation = simd_float4x4(rotationX: radians(-90))
        let scaleFactor = 2 / Float(max(gat.width, gat.height)) / 5
        let scale = simd_float4x4(scale: [scaleFactor, scaleFactor, scaleFactor])

        worldEntity.transform.matrix = scale * rotation * translation

        let entity = Entity()
        entity.addChild(worldEntity)

        return entity
    }
}

#else

import Metal

struct MapViewerMapRenderingView: View {
    var map: MapModel
    var resourceManager: ResourceManager

    private let progress = Progress()

    @State private var dragStartOffset: CGPoint?
    @State private var magnification: CGFloat = 1

    var body: some View {
        AsyncContentView {
            try await loadRenderer()
        } content: { renderer in
            MetalViewContainer(renderer: renderer)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let startOffset = dragStartOffset ?? renderer.camera.panOffset
                            dragStartOffset = startOffset

                            let offset = CGPoint(
                                x: startOffset.x + value.translation.width,
                                y: startOffset.y + value.translation.height
                            )
                            renderer.camera.pan(offset: offset)
                        }
                        .onEnded { _ in
                            dragStartOffset = nil
                        }
                )
                .simultaneousGesture(
                    MagnifyGesture()
                        .onChanged { value in
                            renderer.camera.zoom(magnification: magnification * value.magnification)
                        }
                        .onEnded { value in
                            magnification *= value.magnification
                        }
                )
                .simultaneousGesture(
                    SpatialTapGesture()
                        .onEnded { value in
                            renderer.focusTile(at: value.location)
                        }
                )
        } placeholder: {
            ProgressView(progress)
                .progressViewStyle(.circular)
        }
    }

    private func loadRenderer() async throws -> RSWFilePreviewRenderer {
        let world = try await resourceManager.world(mapName: "\(map.name).rsw")
        let worldAssetLoader = WorldAssetLoader()
        let worldAsset = try await worldAssetLoader.load(
            world: world,
            resourceManager: resourceManager,
            progress: progress
        )

        let device = MTLCreateSystemDefaultDevice()!
        let renderer = try RSWFilePreviewRenderer(device: device, worldAsset: worldAsset)
        return renderer
    }
}

#endif
