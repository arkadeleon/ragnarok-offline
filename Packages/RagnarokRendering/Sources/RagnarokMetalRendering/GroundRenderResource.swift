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
        let vertices = asset.ground.mesh.vertices
        vertexCount = vertices.count
        vertexBuffer = device.makeBuffer(
            bytes: vertices,
            length: vertices.count * MemoryLayout<GroundVertex>.stride,
            options: []
        )

        let baseColorTextureImage = asset.ground.textureAtlas.makeCGImage(textureImages: asset.textureImages)
        baseColorTexture = MetalTextureFactory.makeTexture(
            from: baseColorTextureImage,
            device: device,
            label: "ground-base-color"
        )

        let lightmapTextureImage = asset.ground.lightmapAtlas.makeCGImage()
        lightmapTexture = MetalTextureFactory.makeTexture(
            from: lightmapTextureImage,
            device: device,
            label: "ground-lightmap"
        )

        let tileColorImage = asset.ground.tileColorMap.makeCGImage()
        tileColorTexture = MetalTextureFactory.makeTexture(
            from: tileColorImage,
            device: device,
            label: "ground-tile-color"
        )

        light.ambient = asset.lighting.ambient
        light.diffuse = asset.lighting.diffuse
        light.direction = asset.lighting.direction
        light.opacity = asset.lighting.opacity
    }
}
