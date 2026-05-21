//
//  MapViewerMapRenderingView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/5/21.
//

import Metal
import RagnarokRenderAssets
import RagnarokResources
import SwiftUI

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
