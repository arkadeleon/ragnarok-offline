//
//  ResourceManager+Texture.swift
//  RagnarokReality
//
//  Created by Leon Li on 2025/9/28.
//

import CoreGraphics
import ImageRendering
import RagnarokResources
import RealityKit
import TextEncoding

enum WaterTextureError: Error {
    case cannotCreateImage
}

extension ResourceManager {
    public func textures(
        forNames textureNames: some Collection<String>,
        removesMagentaPixels: Bool,
        perTextureCompletionBlock: (@MainActor (String, TextureResource?) -> Void)? = nil
    ) async -> [String : TextureResource] {
        await withTaskGroup(
            of: (String, TextureResource?).self,
            returning: [String : TextureResource].self
        ) { taskGroup in
            for textureName in textureNames {
                taskGroup.addTask {
                    let components = textureName.split(separator: "\\").map(String.init)
                    let texturePath = ResourcePath.textureDirectory.appending(components)
                    let textureImage = try? await self.image(at: texturePath, removesMagentaPixels: removesMagentaPixels)
                    guard let textureImage else {
                        return (textureName, nil)
                    }

                    let texture = try? await TextureResource(
                        image: textureImage,
                        withName: textureName,
                        options: TextureResource.CreateOptions(semantic: .color)
                    )
                    return (textureName, texture)
                }
            }

            var textures: [String : TextureResource] = [:]
            for await (textureName, texture) in taskGroup {
                textures[textureName] = texture
                await perTextureCompletionBlock?(textureName, texture)
            }
            return textures
        }
    }

    public func waterTexture() async throws -> TextureResource {
        let textureImage = await withTaskGroup(
            of: (Int, CGImage?).self,
            returning: CGImage?.self
        ) { taskGroup in
            for i in 0..<32 {
                let textureName = String(format: "water%03d.jpg", i)
                let texturePath = ResourcePath.textureDirectory.appending([K2L("워터"), textureName])
                taskGroup.addTask {
                    let image = try? await self.image(at: texturePath)
                    return (i, image)
                }
            }

            var textureImages: [Int : CGImage?] = [:]
            for await (index, image) in taskGroup {
                textureImages[index] = image
            }

            let size = CGSize(width: 128 * textureImages.count, height: 128)
            let renderer = CGImageRenderer(size: size, flipped: false)
            let image = renderer.image { cgContext in
                for textureIndex in 0..<textureImages.count {
                    if let image = textureImages[textureIndex], let image {
                        let rect = CGRect(x: 128 * textureIndex, y: 0, width: 128, height: 128)
                        cgContext.draw(image, in: rect)
                    }
                }
            }
            return image
        }

        guard let textureImage else {
            throw WaterTextureError.cannotCreateImage
        }

        let texture = try await TextureResource(
            image: textureImage,
            withName: "water",
            options: TextureResource.CreateOptions(semantic: .color)
        )
        return texture
    }
}
