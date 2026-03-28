//
//  MapGroundRendererAdapter.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/23.
//

import Metal
import RagnarokRenderers
import RagnarokSceneAssets
import simd

final class MapGroundRendererAdapter {
    let ground: Ground

    private let renderer: GroundRenderer

    init(
        device: any MTLDevice,
        asset: GroundRenderAsset,
        lighting: WorldLighting
    ) throws {
        let textureImage = asset.ground.textureAtlas.makeCGImage(textureImages: asset.textureImages)
        let lightmapTextureImage = asset.ground.lightmapAtlas.makeCGImage()
        let tileColorImage = asset.ground.tileColorMap.makeCGImage()

        let groundTexture = MapMetalTextureFactory.makeTexture(
            from: textureImage,
            device: device,
            label: "map-ground-atlas"
        )
        let lightmapTexture = MapMetalTextureFactory.makeTexture(
            from: lightmapTextureImage,
            device: device,
            label: "map-ground-lightmap"
        )
        let tileColorTexture = MapMetalTextureFactory.makeTexture(
            from: tileColorImage,
            device: device,
            label: "map-ground-tile-color"
        )

        guard let groundTexture else {
            fatalError("MapGroundRendererAdapter: failed to create ground texture")
        }

        self.ground = asset.ground
        self.renderer = try GroundRenderer(
            device: device,
            ground: asset.ground,
            groundTexture: groundTexture,
            lightmapTexture: lightmapTexture,
            tileColorTexture: tileColorTexture,
            useLightmap: lightmapTextureImage != nil,
            lighting: lighting
        )
    }

    func render(
        atTime time: CFTimeInterval,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        matrices: MapRuntimeRenderer.RenderMatrices
    ) {
        renderer.render(
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            modelMatrix: matrices.modelMatrix,
            viewMatrix: matrices.viewMatrix,
            projectionMatrix: matrices.projectionMatrix,
            normalMatrix: matrices.normalMatrix
        )
    }
}
