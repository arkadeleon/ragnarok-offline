//
//  GroundRenderResource.swift
//  RagnarokRendering
//
//  Created by Leon Li on 2026/3/23.
//

import Metal
import RagnarokRenderAssets
import RagnarokShaders

public class GroundRenderResource {
    struct MeshResource {
        let vertexStart: Int
        let vertexCount: Int
        let texture: (any MTLTexture)?
    }

    let vertexBuffer: (any MTLBuffer)?
    let meshes: [GroundRenderResource.MeshResource]

    let lightmapTexture: (any MTLTexture)?

    var light: WorldLight

    public init(device: any MTLDevice, asset: GroundRenderAsset, light: WorldLight) {
        let vertices = asset.meshes.flatMap(\.vertices)
        vertexBuffer = device.makeBuffer(
            bytes: vertices,
            length: vertices.count * MemoryLayout<GroundVertex>.stride,
            options: []
        )

        var textures: [String : any MTLTexture] = [:]
        for (textureName, textureImage) in asset.textureImages {
            textures[textureName] = MetalTextureFactory.makeTexture(
                from: textureImage,
                device: device,
                label: textureName
            )
        }

        var meshes: [GroundRenderResource.MeshResource] = []
        var vertexStart = 0
        for mesh in asset.meshes {
            let meshResource = GroundRenderResource.MeshResource(
                vertexStart: vertexStart,
                vertexCount: mesh.vertices.count,
                texture: textures[mesh.textureName]
            )
            meshes.append(meshResource)
            vertexStart += mesh.vertices.count
        }
        self.meshes = meshes

        lightmapTexture = MetalTextureFactory.makeTexture(
            from: asset.lightmapTextureImage,
            device: device,
            label: "ground-lightmap-texture"
        )

        self.light = light
    }
}
