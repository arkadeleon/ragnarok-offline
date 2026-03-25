//
//  SkyboxEntity.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/1/23.
//

import CoreGraphics
import ImageRendering
import RagnarokFileFormats
import RealityKit

func angularDistance(_ a: Float, _ b: Float) -> Float {
    let d = abs(a - b).truncatingRemainder(dividingBy: 360)
    return min(d, 360 - d)
}

enum SkyboxError: Error {
    case textureGenerationFailed
}

struct SkyboxConfiguration {
    var center: SIMD3<Float> = .zero
    var radius: Float = 250
    var topColor = CGColor(red: 0.2, green: 0.4, blue: 0.85, alpha: 1.0)
    var horizonColor = CGColor(red: 0.6, green: 0.75, blue: 0.95, alpha: 1.0)
    var bottomColor = CGColor(red: 0.4, green: 0.55, blue: 0.75, alpha: 1.0)

    static func generate(light: RSW.Light, mapWidth: Int, mapHeight: Int) -> SkyboxConfiguration {
        var longitude = Float(light.longitude).truncatingRemainder(dividingBy: 360)
        longitude = longitude < 0 ? longitude + 360 : longitude

        let isEvening = angularDistance(longitude, 0) < 45 || angularDistance(longitude, 180) < 45
        let isMorning = angularDistance(longitude, 90) < 45 || angularDistance(longitude, 270) < 45

        let centerX = Float(mapWidth) / 2
        let centerZ = -Float(mapHeight) / 2
        let center: SIMD3<Float> = [centerX, 0, centerZ]

        let diagonal = sqrtf(Float(mapWidth * mapWidth + mapHeight * mapHeight))
        let cameraMargin: Float = 200
        let radius = diagonal / 2 + cameraMargin

        if isEvening {
            return SkyboxConfiguration(
                center: center,
                radius: radius,
                topColor: CGColor(red: 0.15, green: 0.1, blue: 0.3, alpha: 1.0),
                horizonColor: CGColor(red: 0.9, green: 0.5, blue: 0.3, alpha: 1.0),
                bottomColor: CGColor(red: 0.4, green: 0.3, blue: 0.35, alpha: 1.0)
            )
        }

        if isMorning {
            return SkyboxConfiguration(
                center: center,
                radius: radius,
                topColor: CGColor(red: 0.3, green: 0.5, blue: 0.8, alpha: 1.0),
                horizonColor: CGColor(red: 0.95, green: 0.75, blue: 0.6, alpha: 1.0),
                bottomColor: CGColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 1.0)
            )
        }

        let ambient = (
            r: CGFloat(light.ambientRed),
            g: CGFloat(light.ambientGreen),
            b: CGFloat(light.ambientBlue)
        )

        return SkyboxConfiguration(
            center: center,
            radius: radius,
            topColor: CGColor(
                red: 0.15 + ambient.r * 0.1,
                green: 0.35 + ambient.g * 0.1,
                blue: 0.8 + ambient.b * 0.1,
                alpha: 1.0
            ),
            horizonColor: CGColor(red: 0.55, green: 0.7, blue: 0.92, alpha: 1.0),
            bottomColor: CGColor(red: 0.35, green: 0.5, blue: 0.72, alpha: 1.0)
        )
    }
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
