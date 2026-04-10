//
//  GroundEntity.swift
//  RagnarokRealityRendering
//
//  Created by Leon Li on 2025/9/28.
//

import Metal
import RagnarokRenderAssets
import RagnarokShaders
import RealityKit

#if os(iOS) || os(macOS)
import RagnarokRealitySurfaceShaders
#endif

enum GroundEntityError: Error {
    case emptyGroundMesh
    case invalidGroundVertexLayout
}

extension Entity {
    public convenience init(from groundAsset: GroundRenderAsset) async throws {
        self.init()

        let mesh = try makeMesh(groundAsset: groundAsset)
        let material = try await makeMaterial(groundAsset: groundAsset)

        components.set(ModelComponent(mesh: mesh, materials: [material]))
    }

    private func makeMesh(groundAsset: GroundRenderAsset) throws -> MeshResource {
        let vertexCount = groundAsset.mesh.vertices.count
        guard vertexCount > 0 else {
            throw GroundEntityError.emptyGroundMesh
        }

        guard let positionOffset = MemoryLayout<GroundVertex>.offset(of: \.position),
              let normalOffset = MemoryLayout<GroundVertex>.offset(of: \.normal),
              let textureOffset = MemoryLayout<GroundVertex>.offset(of: \.textureCoordinate),
              let lightmapOffset = MemoryLayout<GroundVertex>.offset(of: \.lightmapCoordinate),
              let tileColorOffset = MemoryLayout<GroundVertex>.offset(of: \.tileColorCoordinate) else {
            throw GroundEntityError.invalidGroundVertexLayout
        }

        let descriptor = LowLevelMesh.Descriptor(
            vertexCapacity: vertexCount,
            vertexAttributes: [
                LowLevelMesh.Attribute(semantic: .position, format: .float3, offset: positionOffset),
                LowLevelMesh.Attribute(semantic: .normal, format: .float3, offset: normalOffset),
                LowLevelMesh.Attribute(semantic: .uv0, format: .float2, offset: textureOffset),
                LowLevelMesh.Attribute(semantic: .uv1, format: .float2, offset: lightmapOffset),
                LowLevelMesh.Attribute(semantic: .uv2, format: .float2, offset: tileColorOffset),
            ],
            vertexLayouts: [
                LowLevelMesh.Layout(bufferIndex: 0, bufferStride: MemoryLayout<GroundVertex>.stride),
            ],
            indexCapacity: vertexCount,
            indexType: .uint32
        )
        let lowLevelMesh = try LowLevelMesh(descriptor: descriptor)

        lowLevelMesh.replaceUnsafeMutableBytes(bufferIndex: 0) { rawBuffer in
            groundAsset.mesh.vertices.withUnsafeBytes { sourceBuffer in
                rawBuffer[0..<sourceBuffer.count].copyBytes(from: sourceBuffer)
            }
        }

        lowLevelMesh.replaceUnsafeMutableIndices { rawBuffer in
            let indices = rawBuffer.bindMemory(to: UInt32.self)
            for index in 0..<vertexCount {
                indices[index] = UInt32(index)
            }
        }

        var bounds = BoundingBox.empty
        for vertex in groundAsset.mesh.vertices {
            bounds.formUnion(vertex.position)
        }

        let part = LowLevelMesh.Part(
            indexOffset: 0,
            indexCount: groundAsset.mesh.vertices.count,
            topology: .triangle,
            materialIndex: 0,
            bounds: bounds
        )
        lowLevelMesh.parts.replaceAll([part])

        let meshResource = try MeshResource(from: lowLevelMesh)
        return meshResource
    }

    private func makeMaterial(groundAsset: GroundRenderAsset) async throws -> any Material {
        #if os(iOS) || os(macOS)
        let functionConstants = MTLFunctionConstantValues()
        var lightDirection = groundAsset.lighting.direction
        var lightAmbient = groundAsset.lighting.ambient
        var lightDiffuse = groundAsset.lighting.diffuse
        var lightOpacity = groundAsset.lighting.opacity
        var useLightmap = groundAsset.lightmapTextureImage != nil
        functionConstants.setConstantValue(&lightDirection, type: .float3, index: 0)
        functionConstants.setConstantValue(&lightAmbient, type: .float3, index: 1)
        functionConstants.setConstantValue(&lightDiffuse, type: .float3, index: 2)
        functionConstants.setConstantValue(&lightOpacity, type: .float, index: 3)
        functionConstants.setConstantValue(&useLightmap, type: .bool, index: 4)

        let surfaceShader = SurfaceShaders.groundSurfaceShader(constantValues: functionConstants)

        var material = try CustomMaterial(surfaceShader: surfaceShader, lightingModel: .unlit)

        if let textureImage = groundAsset.baseColorTextureImage {
            let texture = try await TextureResource(
                image: textureImage,
                withName: "ground-base-color-texture",
                options: TextureResource.CreateOptions(semantic: .raw)
            )
            material.baseColor = CustomMaterial.BaseColor(texture: CustomMaterial.Texture(texture))
        }

        if let lightmapTextureImage = groundAsset.lightmapTextureImage {
            let lightmapTexture = try await TextureResource(
                image: lightmapTextureImage,
                withName: "ground-lightmap-texture",
                options: TextureResource.CreateOptions(semantic: .raw)
            )
            material.custom.texture = CustomMaterial.Texture(lightmapTexture)
        }

        if let tileColorImage = groundAsset.tileColorTextureImage {
            let tileColorTexture = try await TextureResource(
                image: tileColorImage,
                withName: "ground-tile-color-texture",
                options: TextureResource.CreateOptions(semantic: .raw)
            )
            material.emissiveColor = CustomMaterial.EmissiveColor(texture: CustomMaterial.Texture(tileColorTexture))
        }

        return material
        #else
        var material = PhysicallyBasedMaterial()

        if let textureImage = groundAsset.baseColorTextureImage {
            let texture = try await TextureResource(
                image: textureImage,
                withName: "ground-base-color-texture",
                options: TextureResource.CreateOptions(semantic: .color)
            )
            material.baseColor = PhysicallyBasedMaterial.BaseColor(texture: MaterialParameters.Texture(texture))
            material.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 0.9)
        }

        return material
        #endif
    }
}
