//
//  SkyboxEntity.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/1/23.
//

import CoreGraphics
import ImageRendering
import RealityKit

enum SkyboxError: Error {
    case textureGenerationFailed
}

class SkyboxEntity: Entity {
    convenience init(configuration: SkyboxConfiguration) async throws {
        self.init()

        let mesh = try await MeshResource.generateInvertedSphere(radius: configuration.radius, segments: 36)

        guard let skyTextureImage = CGImage.generateSkyTexture(
            topColor: configuration.topColor,
            horizonColor: configuration.horizonColor,
            bottomColor: configuration.bottomColor
        ) else {
            throw SkyboxError.textureGenerationFailed
        }

        let skyTexture = try await TextureResource(
            image: skyTextureImage,
            withName: "sky.texture",
            options: TextureResource.CreateOptions(semantic: .color)
        )

        let material = UnlitMaterial(texture: skyTexture)

        components.set(ModelComponent(mesh: mesh, materials: [material]))

        position = configuration.center
    }
}

extension MeshResource {
    static func generateInvertedSphere(radius: Float, segments: Int) async throws -> MeshResource {
        var positions: [SIMD3<Float>] = []
        var textureCoordinates: [SIMD2<Float>] = []
        var indices: [UInt32] = []

        for lat in 0...segments {
            let theta = Float.pi * Float(lat) / Float(segments)
            let sinTheta = sin(theta)
            let cosTheta = cos(theta)

            for lon in 0...segments {
                let phi = 2 * Float.pi * Float(lon) / Float(segments)
                let sinPhi = sin(phi)
                let cosPhi = cos(phi)

                let x = cosPhi * sinTheta
                let y = cosTheta
                let z = sinPhi * sinTheta

                positions.append(SIMD3(x, y, z) * radius)
                textureCoordinates.append(SIMD2(
                    Float(lon) / Float(segments),
                    Float(lat) / Float(segments)
                ))
            }
        }

        for lat in 0..<segments {
            for lon in 0..<segments {
                let first = UInt32(lat * (segments + 1) + lon)
                let second = first + UInt32(segments + 1)

                indices.append(contentsOf: [first + 1, first, second])
                indices.append(contentsOf: [first + 1, second, second + 1])
            }
        }

        var descriptor = MeshDescriptor(name: "skybox")
        descriptor.positions = MeshBuffer(positions)
        descriptor.textureCoordinates = MeshBuffer(textureCoordinates)
        descriptor.primitives = .triangles(indices)

        return try await MeshResource(from: [descriptor])
    }
}

extension CGImage {
    static func generateSkyTexture(
        topColor: CGColor,
        horizonColor: CGColor,
        bottomColor: CGColor,
        size: CGSize = CGSize(width: 512, height: 256)
    ) -> CGImage? {
        let renderer = CGImageRenderer(size: size, flipped: false)
        return renderer.image { context in
            guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
                return
            }

            let colors = [topColor, horizonColor, bottomColor] as CFArray
            let locations: [CGFloat] = [0.0, 0.5, 1.0]

            guard let gradient = CGGradient(
                colorsSpace: colorSpace,
                colors: colors,
                locations: locations
            ) else {
                return
            }

            let startPoint = CGPoint(x: size.width / 2, y: 0)
            let endPoint = CGPoint(x: size.width / 2, y: size.height)

            context.drawLinearGradient(
                gradient,
                start: startPoint,
                end: endPoint,
                options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
            )
        }
    }
}
