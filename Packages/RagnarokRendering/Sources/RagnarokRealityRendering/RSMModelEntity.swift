//
//  RSMModelEntity.swift
//  RagnarokRealityRendering
//
//  Created by Leon Li on 2025/2/26.
//

import Metal
import RagnarokFileFormats
import RagnarokRenderAssets
import RealityKit

#if os(iOS) || os(macOS)
import RagnarokRealitySurfaceShaders
#endif

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

        self.init()

        let mesh = try await {
            var descriptors: [MeshDescriptor] = []
            for (index, mesh) in modelAsset.meshes.enumerated() {
                var descriptor = MeshDescriptor(name: mesh.textureName)
                descriptor.positions = MeshBuffer(mesh.vertices.map({ $0.position }))
                descriptor.normals = MeshBuffer(mesh.vertices.map({ $0.normal }))
                descriptor.textureCoordinates = MeshBuffer(mesh.vertices.map({ $0.textureCoordinate }))

                let indices = (0..<descriptor.positions.count).map(UInt32.init)
                descriptor.primitives = .triangles(indices + indices.reversed())

                descriptor.materials = .allFaces(UInt32(index))

                descriptors.append(descriptor)
            }

            let mesh = try await MeshResource(from: descriptors)
            return mesh
        }()

        #if os(iOS) || os(macOS)
        let functionConstants = MTLFunctionConstantValues()
        var lightDirection = modelAsset.lighting.direction
        var lightAmbient = modelAsset.lighting.ambient
        var lightDiffuse = modelAsset.lighting.diffuse
        var lightOpacity = modelAsset.lighting.opacity
        functionConstants.setConstantValue(&lightDirection, type: .float3, index: 0)
        functionConstants.setConstantValue(&lightAmbient, type: .float3, index: 1)
        functionConstants.setConstantValue(&lightDiffuse, type: .float3, index: 2)
        functionConstants.setConstantValue(&lightOpacity, type: .float, index: 3)

        let surfaceShader = SurfaceShaders.modelSurfaceShader(constantValues: functionConstants)

        let materials = try modelAsset.meshes.map { mesh -> any Material in
            var material = try CustomMaterial(surfaceShader: surfaceShader, lightingModel: .unlit)
            material.opacityThreshold = 0.9999
            material.blending = .transparent(opacity: 1.0)

            if let texture = textures[mesh.textureName] {
                material.baseColor = CustomMaterial.BaseColor(texture: CustomMaterial.Texture(texture))
            }

            return material
        }
        #else
        let materials = try modelAsset.meshes.map { mesh -> any Material in
            if let texture = textures[mesh.textureName] {
                var material = PhysicallyBasedMaterial()
                material.baseColor = PhysicallyBasedMaterial.BaseColor(texture: MaterialParameters.Texture(texture))
                material.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 0.8)
                material.opacityThreshold = 0.9999
                material.blending = .transparent(opacity: 1.0)
                return material
            } else {
                let material = SimpleMaterial()
                return material
            }
        }
        #endif

        components.set(ModelComponent(mesh: mesh, materials: materials))

        let scale = 2 / modelAsset.boundingBox.range.max()
        self.scale = [scale, scale, scale]

        self.name = modelAsset.name
    }
}
