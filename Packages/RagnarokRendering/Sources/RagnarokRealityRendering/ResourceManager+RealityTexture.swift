//
//  ResourceManager+RealityTexture.swift
//  RagnarokRealityRendering
//
//  Created by Leon Li on 2025/9/28.
//

import RagnarokResources
import RealityKit

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
                        image: textureImage.cgImage,
                        withName: textureName,
                        options: TextureResource.CreateOptions(semantic: .raw)
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
}
