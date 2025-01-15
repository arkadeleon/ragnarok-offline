//
//  Entity+RSM.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/6/7.
//

import CoreGraphics
import RealityKit
import ROFileFormats

extension Entity {
    public static func loadModel(rsm: RSM, instance: float4x4, textureProvider: (String) async throws -> CGImage?) async throws -> Entity {
        var textureNames = [String]()
        let model = Model(rsm: rsm, instance: instance) { textureName in
            textureNames.append(textureName)
            return nil
        }

        var materials: [any Material] = []
        for textureName in textureNames {
            guard let cgImage = try? await textureProvider(textureName) else {
                materials.append(SimpleMaterial())
                continue
            }
            guard let textureResource = try? TextureResource.generate(from: cgImage, withName: textureName, options: .init(semantic: .color)) else {
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
