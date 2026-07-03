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
        case .spr(let definition):
            let asset = try await loadAsset(with: definition)
            return .spr(asset)
        case .str(let definition):
            let asset = try await loadAsset(with: definition)
            return .str(asset)
        }
    }

    private func loadAsset(with definition: Effect3DDefinition) async throws -> Effect3DAsset {
        var textures: [Effect3DAsset.Texture] = []

        if let spriteName = definition.spriteName {
            let spritePath = ResourcePath.spriteDirectory
                .appending(K2L("이팩트"))
                .appending(spriteName)

            async let actData = resourceManager.contentsOfResource(at: spritePath.appendingPathExtension("act"))
            async let sprData = resourceManager.contentsOfResource(at: spritePath.appendingPathExtension("spr"))

            let act = try await ACT(data: actData)
            let spr = try await SPR(data: sprData)
            let spriteImages = spr.imagesBySpriteType()
            let actionFrames = act.action(at: 0)?.frames ?? []
            let frames = definition.playSprite ? actionFrames : Array(actionFrames.prefix(1))
            for frame in frames {
                if let texture = effect3DTexture(for: frame, spriteImages: spriteImages) {
                    textures.append(texture)
                }
            }
        } else {
            let textureNames: [String]
            if definition.fileNames.isEmpty {
                textureNames = definition.fileName.map { [$0] } ?? []
            } else {
                textureNames = definition.fileNames
            }

            for textureName in textureNames {
                let texturePath = ResourcePath.textureDirectory.appending(subpath: textureName)
                let removesMagentaPixels = textureName.lowercased().hasSuffix(".bmp")
                let image = try await resourceManager.image(at: texturePath, removesMagentaPixels: removesMagentaPixels)
                let texture = Effect3DAsset.Texture(image: image.cgImage, sizeFactor: [1, 1])
                textures.append(texture)
            }
        }

        let asset = Effect3DAsset(definition: definition, textures: textures)
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

    private func loadAsset(with definition: SPREffectDefinition) async throws -> SPREffectAsset {
        let spritePath = ResourcePath.spriteDirectory
            .appending(K2L("이팩트"))
            .appending(definition.fileName)

        async let actData = resourceManager.contentsOfResource(at: spritePath.appendingPathExtension("act"))
        async let sprData = resourceManager.contentsOfResource(at: spritePath.appendingPathExtension("spr"))

        let act = try await ACT(data: actData)
        let spr = try await SPR(data: sprData)

        let action = act.action(at: definition.actionIndex)
        let animation = action?.animation(using: spr.imagesBySpriteType())
        let frameImages = animation?.frames.compactMap { $0 } ?? []
        let frameInterval = definition.frameInterval ?? TimeInterval(animation?.frameInterval ?? 1 / 12)
        let frameSize = CGSize(
            width: animation?.frameWidth ?? 0,
            height: animation?.frameHeight ?? 0
        )

        let asset = SPREffectAsset(
            definition: definition,
            frameImages: frameImages,
            frameInterval: frameInterval,
            frameSize: frameSize
        )
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

    private func effect3DTexture(for frame: ACT.Frame, spriteImages: [SPR.SpriteType : [CGImage?]]) -> Effect3DAsset.Texture? {
        guard let layer = frame.layers.first(where: { $0.spriteIndex >= 0 }),
              let spriteType = SPR.SpriteType(rawValue: Int(layer.spriteType)),
              let images = spriteImages[spriteType] else {
            return nil
        }

        let spriteIndex = Int(layer.spriteIndex)
        guard images.indices.contains(spriteIndex),
              let image = images[spriteIndex] else {
            return nil
        }

        let sizeFactor: SIMD2<Float> = [
            Float(image.width) * layer.scale.x / 100,
            Float(image.height) * layer.scale.y / 100,
        ]
        let texture = Effect3DAsset.Texture(image: image, sizeFactor: sizeFactor)
        return texture
    }
}
