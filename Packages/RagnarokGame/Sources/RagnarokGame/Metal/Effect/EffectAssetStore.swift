//
//  EffectAssetStore.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/30.
//

import Foundation
import RagnarokEffects
import RagnarokRenderAssets
import RagnarokResources

@MainActor
final class EffectAssetStore {
    private let loader: EffectAssetLoader

    private var assets: [String : EffectAsset] = [:]
    private var loadTasks: [String : Task<EffectAsset, any Error>] = [:]

    init(resourceManager: ResourceManager) {
        self.loader = EffectAssetLoader(resourceManager: resourceManager)
    }

    func asset(for definition: EffectDefinition) async throws -> EffectAsset {
        let assetKey = definition.assetKey
        if let asset = assets[assetKey] {
            return asset
        }
        if let task = loadTasks[assetKey] {
            return try await task.value
        }

        let task = Task { [loader] in
            try await loader.loadAsset(with: definition)
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
}
