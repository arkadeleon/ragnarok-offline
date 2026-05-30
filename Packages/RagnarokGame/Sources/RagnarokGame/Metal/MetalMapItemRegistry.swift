//
//  MetalMapItemRegistry.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

#if !os(visionOS)

import RagnarokModels
import simd

@MainActor final class MetalMapItemRegistry {
    private(set) var items: [GameObjectID: MetalMapItem] = [:]

    func add(_ item: MetalMapItem) {
        items[item.objectID] = item
    }

    func remove(objectID: GameObjectID) {
        items.removeValue(forKey: objectID)
    }

    func item(for objectID: GameObjectID) -> MetalMapItem? {
        items[objectID]
    }

    func nearestItem(fromPosition position: SIMD2<Int>) -> MetalMapItem? {
        items.values.min {
            distanceSquared($0.gridPosition, to: position) < distanceSquared($1.gridPosition, to: position)
        }
    }

    private func distanceSquared(_ a: SIMD2<Int>, to b: SIMD2<Int>) -> Int {
        let d = a &- b
        return d.x * d.x + d.y * d.y
    }
}

#endif
