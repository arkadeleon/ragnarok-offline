//
//  Entity+Water.swift
//  RagnarokReality
//
//  Created by Leon Li on 2025/9/29.
//

import RagnarokFileFormats
import RagnarokRenderers
import RealityKit
import RagnarokResources

extension Entity {
    public static func waterEntity(gnd: GND, rsw: RSW, resourceManager: ResourceManager) async throws -> Entity {
        let water = Water(gnd: gnd, rsw: rsw)

        if water.mesh.vertices.isEmpty {
            return Entity()
        }

        let mesh = try await {
            var descriptor = MeshDescriptor(name: "water")
            descriptor.positions = MeshBuffer(water.mesh.vertices.map({ $0.position }))
            descriptor.textureCoordinates = MeshBuffer(water.mesh.vertices.map({
                SIMD2(x: $0.textureCoordinate.x, y: $0.textureCoordinate.y)
            }))

            let indices = (0..<descriptor.positions.count).map(UInt32.init)
            descriptor.primitives = .triangles(indices)

            descriptor.materials = .allFaces(0)

            let mesh = try await MeshResource(from: [descriptor])
            return mesh
        }()

        let texture = try? await resourceManager.waterTexture()

        let materials: [any Material]
        if let texture {
            var material = PhysicallyBasedMaterial()
            material.baseColor = PhysicallyBasedMaterial.BaseColor(texture: MaterialParameters.Texture(texture))
            material.textureCoordinateTransform = MaterialParameterTypes.TextureCoordinateTransform(scale: [1 / Float(32), 1])
            materials = [material]
        } else {
            let material = SimpleMaterial()
            materials = [material]
        }

        let waterEntity = Entity(components: [
            ModelComponent(mesh: mesh, materials: materials),
            OpacityComponent(opacity: 0.6),
        ])

        let frames: [SIMD2<Float>] = (0..<32).map { frameIndex in
            [Float(frameIndex) / 32, 0]
        }
        let animationDefinition = SampledAnimation(
            frames: frames,
            name: "flow",
            tweenMode: .hold,
            frameInterval: 1 / 30,
            isAdditive: false,
            bindTarget: .material(0).textureCoordinate.offset,
            repeatMode: .repeat
        )
        let animationResource = try AnimationResource.generate(with: animationDefinition)
        waterEntity.playAnimation(animationResource)

        return waterEntity
    }
}
