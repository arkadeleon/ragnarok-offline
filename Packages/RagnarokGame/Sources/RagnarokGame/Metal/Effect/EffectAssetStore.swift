//
//  EffectAssetStore.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/30.
//

import Foundation
import Metal
import MetalKit
import RagnarokFileFormats
import RagnarokRenderAssets
import RagnarokRenderers
import RagnarokResources

enum EffectAsset: @unchecked Sendable {
    case str(effect: STREffect, textures: [String : any MTLTexture])
    case cylinder(texture: any MTLTexture)
}

@MainActor
final class EffectAssetStore {
    private let device: any MTLDevice
    private let resourceManager: ResourceManager

    private var assets: [String : EffectAsset] = [:]
    private var loadTasks: [String : Task<EffectAsset, any Error>] = [:]

    init(device: any MTLDevice, resourceManager: ResourceManager) {
        self.device = device
        self.resourceManager = resourceManager
    }

    func asset(for definition: EffectDefinition) async throws -> EffectAsset {
        let assetKey = definition.assetKey
        if let asset = assets[assetKey] {
            return asset
        }
        if let task = loadTasks[assetKey] {
            return try await task.value
        }

        let task: Task<EffectAsset, any Error>
        switch definition {
        case .cylinder(let cylinderDefinition):
            task = Task { [resourceManager, device] in
                try await loadCylinderAsset(
                    definition: cylinderDefinition,
                    resourceManager: resourceManager,
                    device: device
                )
            }
        case .str(let strDefinition):
            task = Task { [resourceManager, device] in
                try await loadSTRAsset(
                    definition: strDefinition,
                    resourceManager: resourceManager,
                    device: device
                )
            }
        }

        loadTasks[assetKey] = task

        do {
            let asset = try await task.value
            assets[assetKey] = asset
            loadTasks[assetKey] = nil
            return asset
        } catch {
            loadTasks[assetKey] = nil
            throw error
        }
    }

    func cancelAllTasks() {
        for task in loadTasks.values {
            task.cancel()
        }

        loadTasks.removeAll()
        assets.removeAll()
    }

    private func loadCylinderAsset(
        definition: CylinderEffectDefinition,
        resourceManager: ResourceManager,
        device: any MTLDevice
    ) async throws -> EffectAsset {
        let texturePath = ResourcePath.effectDirectory
            .appending(definition.textureName)
            .appendingPathExtension("tga")
        let image = try await resourceManager.image(at: texturePath)
        guard let texture = MetalTextureFactory.makeTexture(
            from: image.cgImage,
            device: device,
            label: definition.textureName
        ) else {
            throw EffectAssetStoreError.cannotCreateTexture(texturePath)
        }

        return .cylinder(texture: texture)
    }

    private func loadSTRAsset(
        definition: STREffectDefinition,
        resourceManager: ResourceManager,
        device: any MTLDevice
    ) async throws -> EffectAsset {
        let strPath = ResourcePath.effectDirectory.appending(subpath: definition.fileName)
        let strData = try await resourceManager.contentsOfResource(at: strPath)
        let str = try STR(data: strData)
        let effect = STREffect(str: str)

        let textureLoader = MTKTextureLoader(device: device)
        var textures: [String : any MTLTexture] = [:]

        for frame in effect.frames {
            for sprite in frame.sprites {
                let textureName = sprite.textureName
                guard textures[textureName] == nil else {
                    continue
                }

                let texturePath = ResourcePath.effectDirectory.appending(subpath: textureName)
                guard let textureData = try? await resourceManager.contentsOfResource(at: texturePath),
                      let texture = textureLoader.newTexture(bmpData: textureData) else {
                    continue
                }

                textures[textureName] = texture
            }
        }

        return .str(effect: effect, textures: textures)
    }
}

private enum EffectAssetStoreError: Error {
    case cannotCreateTexture(ResourcePath)
}
