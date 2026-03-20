//
//  MapSceneState.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/20.
//

import Observation

@MainActor
@Observable
public final class MapSceneState {
    public var player: MapObjectState
    public var objects: [UInt32: MapObjectState] = [:]
    public var items: [UInt32: MapItemState] = [:]
    public var selection: MapSelectionState = MapSelectionState()
    public var damageEffects: [MapDamageEffect] = []

    public init(player: MapObjectState) {
        self.player = player
    }

    public func drainDamageEffects() -> [MapDamageEffect] {
        let pending = damageEffects
        damageEffects.removeAll(keepingCapacity: true)
        return pending
    }
}
