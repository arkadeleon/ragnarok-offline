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

    func asset(for reference: EffectReference) async throws -> EffectAsset {
        let assetKey = assetKey(for: reference)
        if let asset = assets[assetKey] {
            return asset
        }
        if let task = loadTasks[assetKey] {
            return try await task.value
        }

        let task = Task { [loader] in
            let definitions = EffectTable.definitions(for: reference).map({ $0.resolved() })
            return try await loader.loadAsset(with: definitions)
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

    private func assetKey(for reference: EffectReference) -> String {
        switch reference {
        case .id(let effectID):
            "id:\(effectID.rawValue)"
        case .name(let name):
            "name:\(name)"
        }
    }
}
