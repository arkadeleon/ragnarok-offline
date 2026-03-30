//
//  ResourceManager+TextureImage.swift
//  RagnarokSceneAssets
//
//  Created by Leon Li on 2025/9/28.
//

import CoreGraphics
import ImageRendering
import RagnarokResources
import TextEncoding

private enum WaterTextureImageError: Error {
    case cannotCreateImage
}

extension ResourceManager {
    public func textureImages(
        forNames textureNames: some Collection<String>,
        removesMagentaPixels: Bool,
        perTextureCompletionBlock: (@MainActor (String, CGImage?) -> Void)? = nil
    ) async -> [String : CGImage] {
        await withTaskGroup(
            of: (String, Resources.Image?).self,
            returning: [String : CGImage].self
        ) { taskGroup in
            for textureName in textureNames {
                taskGroup.addTask {
                    let components = textureName.split(separator: "\\").map(String.init)
                    let texturePath = ResourcePath.textureDirectory.appending(components)
                    let textureImage = try? await self.image(at: texturePath, removesMagentaPixels: removesMagentaPixels)
                    return (textureName, textureImage)
                }
            }

            var textureImages: [String : CGImage] = [:]
            for await (textureName, textureImage) in taskGroup {
                textureImages[textureName] = textureImage?.cgImage
                await perTextureCompletionBlock?(textureName, textureImage?.cgImage)
            }
            return textureImages
        }
    }

    public func waterTextureImage() async throws -> CGImage {
        let textureImage = await withTaskGroup(
            of: (Int, Resources.Image?).self,
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

            var textureImages: [Int : Resources.Image?] = [:]
            for await (index, image) in taskGroup {
                textureImages[index] = image
            }

            let size = CGSize(width: 128 * textureImages.count, height: 128)
            let renderer = CGImageRenderer(size: size, flipped: false)
            let image = renderer.image { cgContext in
                for textureIndex in 0..<textureImages.count {
                    if let image = textureImages[textureIndex], let image {
                        let rect = CGRect(x: 128 * textureIndex, y: 0, width: 128, height: 128)
                        cgContext.draw(image.cgImage, in: rect)
                    }
                }
            }
            return image
        }

        guard let textureImage else {
            throw WaterTextureImageError.cannotCreateImage
        }

        return textureImage
    }
}
