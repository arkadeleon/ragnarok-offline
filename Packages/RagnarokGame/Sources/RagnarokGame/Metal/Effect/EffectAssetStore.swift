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

    private var assetGroups: [String : EffectAssetGroup] = [:]
    private var loadTasks: [String : Task<EffectAssetGroup, any Error>] = [:]

    init(resourceManager: ResourceManager) {
        self.loader = EffectAssetLoader(resourceManager: resourceManager)
    }

    func assetGroup(for reference: EffectReference) async throws -> EffectAssetGroup {
        let assetKey = assetKey(for: reference)
        if let asset = assetGroups[assetKey] {
            return asset
        }
        if let task = loadTasks[assetKey] {
            return try await task.value
        }

        let task = Task { [loader] in
            let definitions = EffectTable.definitions(for: reference)
            return try await loader.loadAssetGroup(with: definitions)
        }

        loadTasks[assetKey] = task

        do {
            let assetGroup = try await task.value
            assetGroups[assetKey] = assetGroup
            loadTasks[assetKey] = nil
            return assetGroup
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
        assetGroups.removeAll()
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
