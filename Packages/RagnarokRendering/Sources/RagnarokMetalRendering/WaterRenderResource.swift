//
//  WaterRenderResource.swift
//  RagnarokMetalRendering
//
//  Created by Leon Li on 2026/3/23.
//

import Metal
import RagnarokRenderAssets
import RagnarokShaders

public class WaterRenderResource {
    let vertexCount: Int
    let vertexBuffer: (any MTLBuffer)?

    let textures: [any MTLTexture]

    var waveSpeed: Float
    var waveHeight: Float
    var wavePitch: Float
    var waterLevel: Float
    var waterAnimationSpeed: Float
    var waterOpacity: Float

    var light: WorldLight

    public init(device: any MTLDevice, asset: WaterRenderAsset, light: WorldLight) {
        let vertices = asset.mesh.vertices
        vertexCount = vertices.count
        if vertexCount > 0 {
            vertexBuffer = device.makeBuffer(
                bytes: vertices,
                length: vertices.count * MemoryLayout<WaterVertex>.stride,
                options: []
            )
        } else {
            vertexBuffer = nil
        }

        textures = asset.textureImages.compactMap {
            MetalTextureFactory.makeTexture(from: $0, device: device, label: "water")
        }

        waveHeight = asset.parameters.waveHeight / 5
        waveSpeed = asset.parameters.waveSpeed
        wavePitch = asset.parameters.wavePitch
        waterLevel = asset.parameters.level / 5
        waterAnimationSpeed = max(Float(asset.parameters.animationSpeed), 1)
        waterOpacity = asset.parameters.opacity

        self.light = light
    }
}
