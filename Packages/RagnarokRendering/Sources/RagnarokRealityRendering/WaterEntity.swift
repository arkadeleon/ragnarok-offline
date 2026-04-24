//
//  WaterEntity.swift
//  RagnarokRealityRendering
//
//  Created by Leon Li on 2025/9/29.
//

import CoreGraphics
import RagnarokCore
import RagnarokRenderAssets
import RagnarokResources
import RealityKit

extension Entity {
    public convenience init(from asset: WaterRenderAsset) async throws {
        self.init()

        if asset.mesh.vertices.isEmpty {
            return
        }

        let mesh = try await {
            var descriptor = MeshDescriptor(name: "water-mesh")
            descriptor.positions = MeshBuffer(asset.mesh.vertices.map({ $0.position }))
            descriptor.textureCoordinates = MeshBuffer(asset.mesh.vertices.map({
                SIMD2(x: $0.textureCoordinate.x, y: $0.textureCoordinate.y)
            }))

            let indices = (0..<descriptor.positions.count).map(UInt32.init)
            descriptor.primitives = .triangles(indices)

            descriptor.materials = .allFaces(0)

            let mesh = try await MeshResource(from: [descriptor])
            return mesh
        }()

        let materials: [any Material]
        let frameCount = asset.textureImages.count
        if frameCount > 0 {
            let frameSize = 128
            let size = CGSize(width: frameSize * frameCount, height: frameSize)
            let renderer = CGImageRenderer(size: size, flipped: false)
            let atlasImage = renderer.image { cgContext in
                for (index, image) in asset.textureImages.enumerated() {
                    let rect = CGRect(x: frameSize * index, y: 0, width: frameSize, height: frameSize)
                    cgContext.draw(image, in: rect)
                }
            }

            if let atlasImage {
                let texture = try await TextureResource(
                    image: atlasImage,
                    withName: "water-texture",
                    options: TextureResource.CreateOptions(semantic: .color)
                )

                var material = PhysicallyBasedMaterial()
                material.baseColor = PhysicallyBasedMaterial.BaseColor(texture: MaterialParameters.Texture(texture))
                material.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 0.2)
                material.textureCoordinateTransform = PhysicallyBasedMaterial.TextureCoordinateTransform(scale: [1 / Float(frameCount), 1])
                materials = [material]
            } else {
                let material = SimpleMaterial()
                materials = [material]
            }
        } else {
            let material = SimpleMaterial()
            materials = [material]
        }

        components.set([
            ModelComponent(mesh: mesh, materials: materials),
            OpacityComponent(opacity: asset.parameters.opacity),
        ])

        let frameCount32 = max(asset.textureImages.count, 1)
        let frames: [SIMD2<Float>] = (0..<frameCount32).map { frameIndex in
            [Float(frameIndex) / Float(frameCount32), 0]
        }
        let animationDefinition = SampledAnimation(
            frames: frames,
            name: "flow",
            tweenMode: .hold,
            frameInterval: Float(max(asset.parameters.animationSpeed, 1)) / 60,
            isAdditive: false,
            bindTarget: .material(0).textureCoordinate.offset,
            repeatMode: .repeat
        )
        let animationResource = try AnimationResource.generate(with: animationDefinition)
        playAnimation(animationResource)
    }
}
