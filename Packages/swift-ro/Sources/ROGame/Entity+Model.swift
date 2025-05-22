//
//  Entity+Model.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/26.
//

import CoreGraphics
import RealityKit
import ROFileFormats
import RORenderers
import RORendering
import ROResources

extension Entity {
    public static func modelEntity(model: ModelResource, resourceManager: ResourceManager) async throws -> Entity {
        let instance = Model.createInstance(
            position: .zero,
            rotation: .zero,
            scale: .one,
            width: 0,
            height: 0
        )

        let modelEntity = try await Entity.modelEntity(rsm: model.rsm, instance: instance, resourceManager: resourceManager)
        return modelEntity
    }

    public static func modelEntity(rsm: RSM, instance: float4x4, resourceManager: ResourceManager) async throws -> Entity {
        let model = Model(rsm: rsm, instance: instance)

        var materials: [any Material] = []
        for mesh in model.meshes {
            let components = mesh.textureName.split(separator: "\\").map(String.init)
            let texturePath = ResourcePath.textureDirectory.appending(components)
            let textureImage = try? await resourceManager.image(at: texturePath, removesMagentaPixels: true)

            guard let textureImage else {
                materials.append(SimpleMaterial())
                continue
            }

            let textureResource = try? await TextureResource(image: textureImage, withName: mesh.textureName, options: .init(semantic: .color))

            guard let textureResource else {
                materials.append(SimpleMaterial())
                continue
            }

            var material = PhysicallyBasedMaterial()
            material.baseColor = .init(texture: .init(textureResource))
            material.blending = .transparent(opacity: 1.0)
            material.opacityThreshold = 0.9999
            materials.append(material)
        }

        let meshDescriptors = model.meshes.enumerated().map { (index, mesh) in
            var meshDescriptor = MeshDescriptor()
            meshDescriptor.positions = MeshBuffer(mesh.vertices.map({ $0.position }))
            meshDescriptor.normals = MeshBuffer(mesh.vertices.map({ $0.normal }))
            meshDescriptor.textureCoordinates = MeshBuffer(mesh.vertices.map({ SIMD2($0.textureCoordinate.x, 1.0 - $0.textureCoordinate.y) }))

            let indices = (0..<meshDescriptor.positions.count).map(UInt32.init)
            meshDescriptor.primitives = .triangles(indices + indices.reversed())

            meshDescriptor.materials = .allFaces(UInt32(index))

            return meshDescriptor
        }
        let mesh = try MeshResource.generate(from: meshDescriptors)

        let modelEntity = ModelEntity(mesh: mesh, materials: materials)

        let scale = 2 / model.boundingBox.range.max()
        modelEntity.scale = [scale, scale, scale]

        return modelEntity
    }
}
