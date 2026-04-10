//
//  GroundRenderAssetAdapter.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/23.
//

import Metal
import RagnarokRenderAssets

final class GroundRenderAssetAdapter {
    let asset: GroundRenderAsset
    let baseColorTexture: (any MTLTexture)?
    let lightmapTexture: (any MTLTexture)?
    let tileColorTexture: (any MTLTexture)?

    init(device: any MTLDevice, asset: GroundRenderAsset) {
        let baseColorTextureImage = asset.ground.textureAtlas.makeCGImage(textureImages: asset.textureImages)
        let lightmapTextureImage = asset.ground.lightmapAtlas.makeCGImage()
        let tileColorImage = asset.ground.tileColorMap.makeCGImage()

        self.asset = asset
        self.baseColorTexture = MetalTextureFactory.makeTexture(
            from: baseColorTextureImage,
            device: device,
            label: "ground-base-color"
        )
        self.lightmapTexture = MetalTextureFactory.makeTexture(
            from: lightmapTextureImage,
            device: device,
            label: "ground-lightmap"
        )
        self.tileColorTexture = MetalTextureFactory.makeTexture(
            from: tileColorImage,
            device: device,
            label: "ground-tile-color"
        )
    }
}
