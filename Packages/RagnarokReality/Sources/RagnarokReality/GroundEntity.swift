//
//  GroundEntity.swift
//  RagnarokReality
//
//  Created by Leon Li on 2025/9/28.
//

import CoreGraphics
import RagnarokRenderers
import RagnarokShaders
import RealityKit

enum GroundEntityError: Error {
    case cannotCreateMetalDevice
    case emptyGroundMesh
    case invalidGroundVertexLayout
}

extension Entity {
    public convenience init(from ground: Ground, textureImages: [String : CGImage]) async throws {
        self.init()

        let mesh = try makeMeshResource(ground: ground)
        let material = try await makeMaterial(ground: ground, textureImages: textureImages)

        components.set(ModelComponent(mesh: mesh, materials: [material]))
    }

    private func makeMeshResource(ground: Ground) throws -> MeshResource {
        let vertexCount = ground.mesh.vertices.count
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
            ground.mesh.vertices.withUnsafeBytes { sourceBuffer in
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
        for vertex in ground.mesh.vertices {
            bounds.formUnion(vertex.position)
        }

        let part = LowLevelMesh.Part(
            indexOffset: 0,
            indexCount: ground.mesh.vertices.count,
            topology: .triangle,
            materialIndex: 0,
            bounds: bounds
        )
        lowLevelMesh.parts.replaceAll([part])

        let meshResource = try MeshResource(from: lowLevelMesh)
        return meshResource
    }

    private func makeMaterial(ground: Ground, textureImages: [String : CGImage]) async throws -> any Material {
        #if os(iOS) || os(macOS)
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw GroundEntityError.cannotCreateMetalDevice
        }
        let library = try device.makeDefaultLibrary(bundle: .module)
        let surfaceShader = CustomMaterial.SurfaceShader(named: "groundSurface", in: library)

        var material = try CustomMaterial(surfaceShader: surfaceShader, lightingModel: .unlit)

        if let textureImage = ground.textureAtlas.makeCGImage(textureImages: textureImages) {
            let texture = try await TextureResource(
                image: textureImage,
                withName: "ground-texture",
                options: TextureResource.CreateOptions(semantic: .color)
            )
            material.baseColor = CustomMaterial.BaseColor(texture: CustomMaterial.Texture(texture))
        }

        if let lightmapTextureImage = ground.lightmapAtlas.makeCGImage() {
            let lightmapTexture = try await TextureResource(
                image: lightmapTextureImage,
                withName: "ground-lightmap-texture",
                options: TextureResource.CreateOptions(semantic: .color)
            )
            material.custom.value.x = 1
            material.custom.texture = CustomMaterial.Texture(lightmapTexture)
        }

        return material
        #else
        var material = PhysicallyBasedMaterial()

        if let textureImage = ground.textureAtlas.makeCGImage(textureImages: textureImages) {
            let texture = try await TextureResource(
                image: textureImage,
                withName: "ground-texture",
                options: TextureResource.CreateOptions(semantic: .color)
            )
            material.baseColor = PhysicallyBasedMaterial.BaseColor(texture: MaterialParameters.Texture(texture))
            material.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 0.9)
        }

        return material
        #endif
    }
}
