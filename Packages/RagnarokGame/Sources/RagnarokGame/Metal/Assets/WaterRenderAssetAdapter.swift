//
//  WaterRenderAssetAdapter.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/23.
//

import Metal
import RagnarokRenderAssets

final class WaterRenderAssetAdapter {
    let asset: WaterRenderAsset
    let texture: (any MTLTexture)?

    init(device: any MTLDevice, asset: WaterRenderAsset) {
        self.asset = asset
        self.texture = MetalTextureFactory.makeTexture(
            from: asset.textureImage,
            device: device,
            label: "water"
        )
    }
}
