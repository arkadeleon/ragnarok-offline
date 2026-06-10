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

    var light: WorldLight

    public init(device: any MTLDevice, asset: GroundRenderAsset, light: WorldLight) {
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

        self.light = light
    }
}
