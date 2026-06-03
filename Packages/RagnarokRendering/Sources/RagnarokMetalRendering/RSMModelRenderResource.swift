//
//  RSMModelRenderResource.swift
//  RagnarokMetalRendering
//
//  Created by Leon Li on 2026/3/23.
//

import Metal
import RagnarokCore
import RagnarokRenderAssets
import RagnarokShaders
import simd

public class RSMModelRenderResource {
    struct MeshResource {
        let vertexCount: Int
        let vertexBuffer: (any MTLBuffer)?
        let texture: (any MTLTexture)?
    }

    struct NodeResource {
        let nodeIndex: Int
        let meshes: [RSMModelRenderResource.MeshResource]
    }

    let nodes: [RSMModelRenderResource.NodeResource]
    let restPoseBoneMatrices: [ModelBoneUniforms]
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

        self.nodes = asset.nodes.map { node in
            NodeResource(
                nodeIndex: node.index,
                meshes: node.meshes.map { mesh in
                    MeshResource(
                        vertexCount: mesh.vertices.count,
                        vertexBuffer: mesh.vertices.isEmpty ? nil : device.makeBuffer(
                            bytes: mesh.vertices,
                            length: mesh.vertices.count * MemoryLayout<ModelVertex>.stride,
                            options: []
                        ),
                        texture: textures[textureNamespace + mesh.textureName]
                    )
                }
            )
        }
        self.restPoseBoneMatrices = asset.makeRestPoseBoneMatrices()
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

extension RSMModelRenderAsset {
    func makeRestPoseBoneMatrices() -> [ModelBoneUniforms] {
        let nodeCount = nodes.count
        var worldForChildren = [simd_float4x4](repeating: matrix_identity_float4x4, count: nodeCount)
        var bones = [ModelBoneUniforms](
            repeating: ModelBoneUniforms(
                boneMatrix: matrix_identity_float4x4,
                boneNormalMatrix: matrix_identity_float3x3
            ),
            count: nodeCount
        )

        let centerCorrection = matrix_translate(matrix_identity_float4x4, centerCorrection)

        // asset.nodes is DFS-ordered (parents before children), so a single forward
        // sweep can resolve each node's world transform from its parent's cached value.
        for node in nodes {
            let parentWorldChildren: simd_float4x4
            if let parent = node.parent {
                parentWorldChildren = worldForChildren[parent.index]
            } else {
                parentWorldChildren = matrix_identity_float4x4
            }

            let local = restPoseLocalForChildrenMatrix(node)
            let transform = local
                * matrix_translate(matrix_identity_float4x4, node.offset)
                * simd_float4x4(node.transformMatrix)

            worldForChildren[node.index] = parentWorldChildren * local

            let boneMatrix = centerCorrection * parentWorldChildren * transform
            bones[node.index] = ModelBoneUniforms(
                boneMatrix: boneMatrix,
                boneNormalMatrix: simd_float3x3(boneMatrix).inverse.transpose
            )
        }

        return bones
    }

    private func restPoseLocalForChildrenMatrix(_ node: RSMModelNode) -> simd_float4x4 {
        var m = matrix_identity_float4x4
        m = matrix_translate(m, node.position)
        let quaternion: simd_quatf
        if node.rotationKeyframes.isEmpty {
            quaternion = simd_quatf(angle: node.rotationAngle, axis: node.rotationAxis)
        } else {
            quaternion = node.rotationKeyframes[0].quaternion
        }
        m *= simd_float4x4(quaternion)
        m = matrix_scale(m, node.scale)
        return m
    }
}
