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
    public var objects: [UInt32 : MapObjectState] = [:]
    public var items: [UInt32 : MapItemState] = [:]
    public var selection: MapSelectionState = MapSelectionState()
    public var damageEffects: [MapDamageEffect] = []
    public let overlaySnapshot = MapOverlaySnapshot()

    public init(player: MapObjectState) {
        self.player = player
    }

    func pruneExpiredDamageEffects(now: ContinuousClock.Instant = .now) {
        damageEffects.removeAll {
            $0.isExpired(at: now)
        }
    }
}

extension MapSceneState {
    func nearestMonster(fromPosition position: SIMD2<Int>) -> MapObjectState? {
        objects.values
            .filter {
                $0.object.type == .monster
            }
            .min {
                distanceSquared($0.gridPosition, to: position) < distanceSquared($1.gridPosition, to: position)
            }
    }

    func nearestNPC(fromPosition position: SIMD2<Int>) -> MapObjectState? {
        objects.values
            .filter {
                $0.object.type == .npc
            }
            .min {
                distanceSquared($0.gridPosition, to: position) < distanceSquared($1.gridPosition, to: position)
            }
    }

    func nearestItem(fromPosition position: SIMD2<Int>) -> MapItemState? {
        items.values
            .min {
                distanceSquared($0.gridPosition, to: position) < distanceSquared($1.gridPosition, to: position)
            }
    }

    private func distanceSquared(_ a: SIMD2<Int>, to b: SIMD2<Int>) -> Int {
        let dx = a.x - b.x
        let dy = a.y - b.y
        return dx * dx + dy * dy
    }
}
