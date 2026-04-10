//
//  GroundRenderResource.swift
//  RagnarokMetalRendering
//
//  Created by Leon Li on 2026/3/23.
//

import Metal
import RagnarokRenderAssets
import RagnarokShaders

public class GroundRenderResource {
    let vertexCount: Int
    let vertexBuffer: (any MTLBuffer)?

    let baseColorTexture: (any MTLTexture)?
    let lightmapTexture: (any MTLTexture)?
    let tileColorTexture: (any MTLTexture)?

    var light = Light(
        opacity: 1,
        ambient: [1, 1, 1],
        diffuse: [0, 0, 0],
        direction: [0, 1, 0]
    )

    public init(device: any MTLDevice, asset: GroundRenderAsset) {
        let vertices = asset.mesh.vertices
        vertexCount = vertices.count
        vertexBuffer = device.makeBuffer(
            bytes: vertices,
            length: vertices.count * MemoryLayout<GroundVertex>.stride,
            options: []
        )

        baseColorTexture = MetalTextureFactory.makeTexture(
            from: asset.baseColorTextureImage,
            device: device,
            label: "ground-base-color-texture"
        )

        lightmapTexture = MetalTextureFactory.makeTexture(
            from: asset.lightmapTextureImage,
            device: device,
            label: "ground-lightmap-texture"
        )

        tileColorTexture = MetalTextureFactory.makeTexture(
            from: asset.tileColorTextureImage,
            device: device,
            label: "ground-tile-color-texture"
        )

        light.ambient = asset.lighting.ambient
        light.diffuse = asset.lighting.diffuse
        light.direction = asset.lighting.direction
        light.opacity = asset.lighting.opacity
    }
}
