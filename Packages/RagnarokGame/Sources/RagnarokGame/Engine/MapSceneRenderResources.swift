//
//  MapSceneRenderResources.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/8/24.
//

import CoreGraphics
import Metal
import RagnarokRenderAssets
import RagnarokRendering

@MainActor
final class MapSceneRenderResources {
    let device: any MTLDevice

    private(set) var world: WorldRenderResource?
    private(set) var tileSelectorTexture: (any MTLTexture)?

    init(device: any MTLDevice) {
        self.device = device
    }

    func loadWorld(_ asset: WorldAsset) {
        world = WorldRenderResource(device: device, asset: asset)
    }

    func loadTileSelectorTexture(from image: CGImage?) {
        tileSelectorTexture = MetalTextureFactory.makeTexture(
            from: image,
            device: device,
            label: "tile-selector"
        )
    }

    func removeAll() {
        world = nil
        tileSelectorTexture = nil
    }
}
