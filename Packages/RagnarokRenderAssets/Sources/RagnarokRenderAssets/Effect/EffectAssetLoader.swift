//
//  EffectAssetLoader.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/6/30.
//

import CoreGraphics
import Foundation
import RagnarokCore
import RagnarokEffects
import RagnarokFileFormats
import RagnarokResources

public struct EffectAssetLoader: Sendable {
    public let resourceManager: ResourceManager

    public init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager
    }

    public func loadAsset(with definition: EffectDefinition) async throws -> EffectAsset {
        switch definition {
        case .`3D`(let definition):
            let asset = try await loadAsset(with: definition)
            return .`3D`(asset)
        case .cylinder(let definition):
            let asset = try await loadAsset(with: definition)
            return .cylinder(asset)
        case .str(let definition):
            let asset = try await loadAsset(with: definition)
            return .str(asset)
        }
    }

    private func loadAsset(with definition: Effect3DDefinition) async throws -> Effect3DAsset {
        let textureNames: [String]
        if definition.fileNames.isEmpty {
            textureNames = definition.fileName.map { [$0] } ?? []
        } else {
            textureNames = definition.fileNames
        }

        var textureImages: [CGImage] = []
        for textureName in textureNames {
            let texturePath = ResourcePath.textureDirectory.appending(subpath: textureName)
            let image = try await resourceManager.image(
                at: texturePath,
                removesMagentaPixels: textureName.lowercased().hasSuffix(".bmp")
            )
            textureImages.append(image.cgImage)
        }

        let asset = Effect3DAsset(definition: definition, textureImages: textureImages)
        return asset
    }

    private func loadAsset(with definition: CylinderEffectDefinition) async throws -> CylinderEffectAsset {
        let texturePath = ResourcePath.effectDirectory
            .appending(definition.textureName)
            .appendingPathExtension("tga")
        let image = try await resourceManager.image(at: texturePath)

        let asset = CylinderEffectAsset(definition: definition, textureImage: image.cgImage)
        return asset
    }

    private func loadAsset(with definition: STREffectDefinition) async throws -> STREffectAsset {
        let strPath = ResourcePath.effectDirectory.appending(subpath: definition.fileName)
        let strData = try await resourceManager.contentsOfResource(at: strPath)
        let str = try STR(data: strData)
        let effect = STREffect(str: str)

        var textureImages: [String : CGImage] = [:]
        for frame in effect.frames {
            for sprite in frame.sprites {
                let textureName = sprite.textureName
                guard textureImages[textureName] == nil else {
                    continue
                }

                let texturePath = ResourcePath.effectDirectory.appending(subpath: textureName)
                let image = try await resourceManager.image(at: texturePath)

                textureImages[textureName] = image.cgImage
            }
        }

        let asset = STREffectAsset(definition: definition, effect: effect, textureImages: textureImages)
        return asset
    }
}
