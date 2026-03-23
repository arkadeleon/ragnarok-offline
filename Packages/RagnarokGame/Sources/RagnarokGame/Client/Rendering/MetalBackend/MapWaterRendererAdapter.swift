//
//  MapWaterRendererAdapter.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/23.
//

#if os(iOS) || os(macOS)

import Metal
import RagnarokRenderers
import RagnarokSceneAssets
import simd

final class MapWaterRendererAdapter {
    private let renderer: WaterRenderer

    init(
        device: any MTLDevice,
        asset: WaterRenderAsset,
        lighting: WorldLighting
    ) throws {
        let waterTexture = MapMetalTextureFactory.makeTexture(
            from: asset.textureImage,
            device: device,
            label: "map-water-texture"
        )

        guard let waterTexture else {
            fatalError("MapWaterRendererAdapter: failed to create water texture")
        }

        self.renderer = try WaterRenderer(
            device: device,
            water: asset.water,
            textures: [waterTexture],
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
            projectionMatrix: matrices.projectionMatrix
        )
    }
}

#endif
