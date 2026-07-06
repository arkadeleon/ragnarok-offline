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

    public func loadAsset(with definitions: [EffectDefinition]) async throws -> EffectAsset {
        var components: [EffectAssetComponent] = []
        components.reserveCapacity(definitions.count)
        for definition in definitions {
            let component = try await loadComponent(with: definition)
            components.append(component)
        }
        return EffectAsset(components: components)
    }

    private func loadComponent(with definition: EffectDefinition) async throws -> EffectAssetComponent {
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
        var images: [CGImage] = []
        var frames: [Effect3DAsset.Frame] = []

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
            let usedFrames = definition.playSprite ? actionFrames : Array(actionFrames.prefix(1))

            var imageIndicesBySprite: [SIMD2<Int> : Int] = [:]
            for frame in usedFrames {
                var layers: [Effect3DAsset.Layer] = []
                for layer in frame.layers where layer.spriteIndex >= 0 {
                    guard let spriteType = SPR.SpriteType(rawValue: Int(layer.spriteType)),
                          let typedImages = spriteImages[spriteType] else {
                        continue
                    }

                    let spriteIndex = Int(layer.spriteIndex)
                    guard typedImages.indices.contains(spriteIndex),
                          let image = typedImages[spriteIndex] else {
                        continue
                    }

                    let spriteKey = SIMD2<Int>(spriteType.rawValue, spriteIndex)
                    let imageIndex: Int
                    if let index = imageIndicesBySprite[spriteKey] {
                        imageIndex = index
                    } else {
                        imageIndex = images.count
                        images.append(image)
                        imageIndicesBySprite[spriteKey] = imageIndex
                    }

                    layers.append(Effect3DAsset.Layer(
                        imageIndex: imageIndex,
                        sizeFactor: [
                            Float(image.width) * layer.scale.x / 100,
                            Float(image.height) * layer.scale.y / 100,
                        ],
                        offset: [
                            Float(layer.offset.x),
                            Float(layer.offset.y),
                        ],
                        angle: Float(layer.rotationAngle),
                        color: [
                            Float(layer.color.red) / 255,
                            Float(layer.color.green) / 255,
                            Float(layer.color.blue) / 255,
                            Float(layer.color.alpha) / 255,
                        ],
                        isMirrored: layer.isMirrored != 0
                    ))
                }
                frames.append(Effect3DAsset.Frame(layers: layers))
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
                let layer = Effect3DAsset.Layer(imageIndex: images.count, sizeFactor: [1, 1])
                let frame = Effect3DAsset.Frame(layers: [layer])
                frames.append(frame)
                images.append(image.cgImage)
            }
        }

        let asset = Effect3DAsset(definition: definition, images: images, frames: frames)
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
}
