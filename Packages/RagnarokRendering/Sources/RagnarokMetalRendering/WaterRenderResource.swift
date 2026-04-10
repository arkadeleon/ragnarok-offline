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

    var light = Light(
        opacity: 1,
        ambient: [1, 1, 1],
        diffuse: [0, 0, 0],
        direction: [0, 1, 0]
    )

    var waveSpeed: Float = 0
    var waveHeight: Float = 0
    var wavePitch: Float = 0
    var waterLevel: Float = 0
    var animSpeed: Float = 1
    var waterOpacity: Float = 0.6

    public init(device: any MTLDevice, asset: WaterRenderAsset) {
        let vertices = asset.water.mesh.vertices
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

        let texture = asset.textureImage.flatMap {
            MetalTextureFactory.makeTexture(from: $0, device: device, label: "water")
        }
        if let texture {
            textures = [texture]
        } else {
            textures = []
        }

        light.ambient = asset.lighting.ambient
        light.diffuse = asset.lighting.diffuse
        light.direction = asset.lighting.direction
        light.opacity = asset.lighting.opacity
    }
}
