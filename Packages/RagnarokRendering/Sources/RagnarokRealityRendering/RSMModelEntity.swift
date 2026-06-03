//
//  RSMModelEntity.swift
//  RagnarokRealityRendering
//
//  Created by Leon Li on 2025/2/26.
//

import RagnarokCore
import RagnarokRenderAssets
import RealityKit
import simd

extension Entity {
    public convenience init(from modelAsset: RSMModelRenderAsset) async throws {
        let textures = await withTaskGroup(
            of: (String, TextureResource?).self,
            returning: [String : TextureResource].self
        ) { taskGroup in
            for (textureName, textureImage) in modelAsset.textureImages {
                taskGroup.addTask {
                    let texture = try? await TextureResource(
                        image: textureImage,
                        withName: textureName,
                        options: TextureResource.CreateOptions(semantic: .raw)
                    )
                    return (textureName, texture)
                }
            }

            var textures: [String : TextureResource] = [:]
            for await (textureName, texture) in taskGroup {
                textures[textureName] = texture
            }
            return textures
        }

        let scale = 2 / modelAsset.boundingBox.range.max()

        self.init()
        name = modelAsset.name
        transform.scale = [scale, scale, scale]

        if let rootNode = modelAsset.rootNode {
            let centerCorrection = matrix_translate(matrix_identity_float4x4, modelAsset.centerCorrection)

            let rootEntity = try await Entity(from: rootNode, textures: textures)
            rootEntity.transform = Transform(matrix: centerCorrection * rootEntity.transform.matrix)
            addChild(rootEntity)
        }
    }

    private convenience init(from node: RSMModelNode, textures: [String : TextureResource]) async throws {
        self.init()
        name = node.name
        transform = Transform(matrix: node.restPoseLocalMatrix)

        let nodeMeshes = node.meshes.filter { !$0.vertices.isEmpty }
        if !nodeMeshes.isEmpty {
            let meshPositionTransform = matrix_translate(matrix_identity_float4x4, node.offset)
                * simd_float4x4(node.transformMatrix)
            let meshNormalTransform = node.transformMatrix

            var descriptors: [MeshDescriptor] = []
            descriptors.reserveCapacity(nodeMeshes.count)
            for (index, nodeMesh) in nodeMeshes.enumerated() {
                var descriptor = MeshDescriptor(name: nodeMesh.textureName)
                descriptor.positions = MeshBuffer(nodeMesh.vertices.map({ vertex in
                    let position = meshPositionTransform * SIMD4<Float>(vertex.position, 1)
                    return SIMD3<Float>(position.x, position.y, position.z)
                }))
                descriptor.normals = MeshBuffer(nodeMesh.vertices.map({ vertex in
                    meshNormalTransform * vertex.normal
                }))
                descriptor.textureCoordinates = MeshBuffer(nodeMesh.vertices.map({
                    SIMD2(x: $0.textureCoordinate.x, y: 1 - $0.textureCoordinate.y)
                }))

                let indices = (0..<descriptor.positions.count).map(UInt32.init)
                descriptor.primitives = .triangles(indices + indices.reversed())

                descriptor.materials = .allFaces(UInt32(index))

                descriptors.append(descriptor)
            }

            let mesh = try await MeshResource(from: descriptors)

            let materials = nodeMeshes.map { nodeMesh -> any Material in
                if let texture = textures[nodeMesh.textureName] {
                    var material = PhysicallyBasedMaterial()
                    material.baseColor = PhysicallyBasedMaterial.BaseColor(texture: MaterialParameters.Texture(texture))
                    material.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 0.8)
                    material.opacityThreshold = 0.9999
                    material.blending = .transparent(opacity: 1.0)
                    return material
                } else {
                    return SimpleMaterial()
                }
            }

            components.set(ModelComponent(mesh: mesh, materials: materials))
        }

        for child in node.children {
            let childEntity = try await Entity(from: child, textures: textures)
            addChild(childEntity)
        }
    }
}

extension RSMModelNode {
    fileprivate var restPoseLocalMatrix: simd_float4x4 {
        var m = matrix_identity_float4x4
        m = matrix_translate(m, position)
        let quaternion: simd_quatf
        if rotationKeyframes.isEmpty {
            quaternion = simd_quatf(angle: rotationAngle, axis: rotationAxis)
        } else {
            quaternion = rotationKeyframes[0].quaternion
        }
        m *= simd_float4x4(quaternion)
        m = matrix_scale(m, scale)
        return m
    }
}
