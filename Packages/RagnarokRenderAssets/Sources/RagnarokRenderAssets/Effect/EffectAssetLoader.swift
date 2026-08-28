//
//  EffectAssetLoader.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/6/30.
//

import CoreGraphics
import RagnarokCore
import RagnarokEffects
import RagnarokFileFormats
import RagnarokResources

public struct EffectAssetLoader: Sendable {
    public let resourceManager: ResourceManager

    private let cache = EffectAssetCache()

    public init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager
    }

    public func loadAssetGroup(with definitions: [EffectDefinition]) async throws -> EffectAssetGroup {
        var assets: [EffectAsset] = []
        assets.reserveCapacity(definitions.count)
        for definition in definitions {
            let asset = try await loadAsset(with: definition)
            assets.append(asset)
        }
        return EffectAssetGroup(assets: assets)
    }

    private func loadAsset(with definition: EffectDefinition) async throws -> EffectAsset {
        switch definition {
        case .`2D`(let definition):
            let effect = TwoDEffect(definition: definition)
            let texturePath = ResourcePath.textureDirectory.appending(subpath: definition.fileName)
            let removesMagentaPixels = definition.fileName.lowercased().hasSuffix(".bmp")
            let image = try await resourceManager.image(at: texturePath, removesMagentaPixels: removesMagentaPixels)
            return .`2D`(effect, textureImage: image.cgImage)
        case .`3D`(let definition):
            let effect = ThreeDEffect(definition: definition)
            let animation: ThreeDAnimation
            switch effect.kind {
            case .sprite(let spriteName, let playSprite):
                animation = try await loadThreeDAnimation(spriteName: spriteName, playSprite: playSprite)
            case .textures(let fileNames):
                animation = try await loadThreeDAnimation(textureNames: fileNames)
            }
            return .`3D`(effect, animation)
        case .cylinder(let definition):
            let effect = CylinderEffect(definition: definition)
            let texturePath = ResourcePath.effectDirectory.appending(subpath: definition.textureName)
            let image = try await resourceManager.image(at: texturePath)
            return .cylinder(effect, textureImage: image.cgImage)
        case .spr(let definition):
            let effect = SPREffect(definition: definition)
            let animation = try await loadSPRAnimation(
                fileName: definition.fileName,
                actionIndex: definition.actionIndex
            )
            return .spr(effect, animation)
        case .str(let definition):
            let effect = STREffect(definition: definition)
            let animation = try await loadSTRAnimation(fileName: effect.fileName)
            return .str(effect, animation)
        case .wav(let definition):
            let effect = WAVEffect(definition: definition)
            return .wav(effect)
        }
    }

    private func loadThreeDAnimation(spriteName: String, playSprite: Bool) async throws -> ThreeDAnimation {
        try await cache.resource(forIdentifier: "3DEffect/sprite/\(spriteName)#\(playSprite)") {
            let spritePath = ResourcePath.spriteDirectory.appending(subpath: spriteName)

            async let actData = resourceManager.contentsOfResource(at: spritePath.appendingPathExtension("act"))
            async let sprData = resourceManager.contentsOfResource(at: spritePath.appendingPathExtension("spr"))

            let act = try await ACT(data: actData)
            let spr = try await SPR(data: sprData)

            return ThreeDAnimation(act: act, spr: spr, playSprite: playSprite)
        }
    }

    private func loadThreeDAnimation(textureNames: [String]) async throws -> ThreeDAnimation {
        try await cache.resource(forIdentifier: "3DEffect/textures/\(textureNames.joined(separator: "|"))") {
            var images: [CGImage] = []
            for textureName in textureNames {
                let texturePath = ResourcePath.textureDirectory.appending(subpath: textureName)
                let removesMagentaPixels = textureName.lowercased().hasSuffix(".bmp")
                let image = try await resourceManager.image(at: texturePath, removesMagentaPixels: removesMagentaPixels)
                images.append(image.cgImage)
            }

            return ThreeDAnimation(images: images)
        }
    }

    private func loadSPRAnimation(fileName: String, actionIndex: Int) async throws -> SPRAnimation {
        try await cache.resource(forIdentifier: "SPREffect/\(fileName)#\(actionIndex)") {
            let spritePath = ResourcePath.spriteDirectory
                .appending(K2L("이팩트"))
                .appending(fileName)

            async let actData = resourceManager.contentsOfResource(at: spritePath.appendingPathExtension("act"))
            async let sprData = resourceManager.contentsOfResource(at: spritePath.appendingPathExtension("spr"))

            let act = try await ACT(data: actData)
            let spr = try await SPR(data: sprData)

            return SPRAnimation(act: act, spr: spr, actionIndex: actionIndex)
        }
    }

    private func loadSTRAnimation(fileName: String) async throws -> STRAnimation {
        try await cache.resource(forIdentifier: "STREffect/\(fileName)") {
            let strPath = ResourcePath.effectDirectory.appending(subpath: fileName)
            let strData = try await resourceManager.contentsOfResource(at: strPath)
            let str = try STR(data: strData)

            var textureImages: [String : CGImage] = [:]
            let textureNames = Set(str.layers.flatMap(\.textures))
            for textureName in textureNames {
                let texturePath = ResourcePath.effectDirectory.appending(subpath: textureName)
                if let image = try? await resourceManager.image(at: texturePath, removesMagentaPixels: true) {
                    textureImages[textureName] = image.cgImage
                }
            }

            return STRAnimation(str: str, textureImages: textureImages)
        }
    }
}
