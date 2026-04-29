//
//  RSMModelRenderResource.swift
//  RagnarokMetalRendering
//
//  Created by Leon Li on 2026/3/23.
//

import Metal
import RagnarokRenderAssets
import RagnarokShaders
import simd

public class RSMModelRenderResource {
    struct MeshResource {
        let vertexCount: Int
        let vertexBuffer: (any MTLBuffer)?
        let texture: (any MTLTexture)?
    }

    let meshes: [RSMModelRenderResource.MeshResource]
    let instanceCount: Int
    let instanceBuffer: (any MTLBuffer)?

    var light = Light(
        opacity: 1,
        ambient: [1, 1, 1],
        diffuse: [0, 0, 0],
        direction: [0, 1, 0]
    )

    public convenience init(device: any MTLDevice, asset: RSMModelRenderAsset) {
        self.init(device: device, prototype: asset, instances: [asset.instance])
    }

    public init(device: any MTLDevice, prototype asset: RSMModelRenderAsset, instances: [RSMModelInstance]) {
        let textures = Self.makeTextures(from: asset, device: device)
        let textureNamespace = Self.textureNamespace(for: asset)

        self.meshes = asset.meshes.map { mesh in
            MeshResource(
                vertexCount: mesh.vertices.count,
                vertexBuffer: device.makeBuffer(
                    bytes: mesh.vertices,
                    length: mesh.vertices.count * MemoryLayout<ModelVertex>.stride,
                    options: []
                ),
                texture: textures[textureNamespace + mesh.textureName]
            )
        }
        self.instanceCount = instances.count
        self.instanceBuffer = Self.makeInstanceBuffer(device: device, instances: instances)

        light.ambient = asset.lighting.ambient
        light.diffuse = asset.lighting.diffuse
        light.direction = asset.lighting.direction
        light.opacity = asset.lighting.opacity
    }
}

extension RSMModelRenderResource {
    private static func makeInstanceBuffer(
        device: any MTLDevice,
        instances: [RSMModelInstance]
    ) -> (any MTLBuffer)? {
        guard !instances.isEmpty else {
            return nil
        }

        let instanceUniforms = instances.map { instance in
            let modelMatrix = instance.matrix
            return ModelInstanceUniforms(
                modelMatrix: modelMatrix,
                normalMatrix: simd_float3x3(modelMatrix).inverse.transpose
            )
        }

        return device.makeBuffer(
            bytes: instanceUniforms,
            length: instanceUniforms.count * MemoryLayout<ModelInstanceUniforms>.stride,
            options: []
        )
    }

    private static func makeTextures(
        from asset: RSMModelRenderAsset,
        device: any MTLDevice
    ) -> [String : any MTLTexture] {
        var textures: [String : any MTLTexture] = [:]

        let namespace = textureNamespace(for: asset)
        for (textureName, textureImage) in asset.textureImages {
            let namespacedTextureName = namespace + textureName
            if textures[namespacedTextureName] != nil {
                continue
            }

            let texture = MetalTextureFactory.makeTexture(
                from: textureImage,
                device: device,
                label: namespacedTextureName
            )
            if let texture {
                textures[namespacedTextureName] = texture
            }
        }

        return textures
    }

    private static func textureNamespace(for asset: RSMModelRenderAsset) -> String {
        "\(asset.name)::"
    }
}
