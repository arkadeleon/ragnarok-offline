//
//  EffectTickContext.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/20.
//

import Foundation

public struct EffectTickContext {
    public let world: any EffectWorldContext
    public let assets: EffectAssetStore?
    public let currentTick: Int
    public let usesMinimalEffects: Bool

    private let onSpawnChild: (EffectSpawnRequest) -> Void

    init(
        world: any EffectWorldContext,
        assets: EffectAssetStore?,
        currentTick: Int,
        usesMinimalEffects: Bool,
        onSpawnChild: @escaping (EffectSpawnRequest) -> Void
    ) {
        self.world = world
        self.assets = assets
        self.currentTick = currentTick
        self.usesMinimalEffects = usesMinimalEffects
        self.onSpawnChild = onSpawnChild
    }

    public func spawnChildEffect(_ request: EffectSpawnRequest) {
        onSpawnChild(request)
    }
}
