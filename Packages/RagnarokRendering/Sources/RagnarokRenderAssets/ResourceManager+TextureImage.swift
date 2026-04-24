//
//  ResourceManager+TextureImage.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2025/9/28.
//

import CoreGraphics
import RagnarokCore
import RagnarokResources

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

    public func waterTextureImages(type waterType: Int32) async -> [CGImage] {
        await withTaskGroup(
            of: (Int, Resources.Image?).self,
            returning: [CGImage].self
        ) { taskGroup in
            for i in 0..<32 {
                let textureName = String(format: "water%d%02d.jpg", waterType, i)
                let texturePath = ResourcePath.textureDirectory.appending([K2L("워터"), textureName])
                taskGroup.addTask {
                    let image = try? await self.image(at: texturePath)
                    return (i, image)
                }
            }

            var textureImages: [Int : Resources.Image] = [:]
            for await (index, image) in taskGroup {
                if let image {
                    textureImages[index] = image
                }
            }

            var images: [CGImage] = []
            for i in 0..<32 {
                if let image = textureImages[i] {
                    images.append(image.cgImage)
                }
            }
            return images
        }
    }
}
