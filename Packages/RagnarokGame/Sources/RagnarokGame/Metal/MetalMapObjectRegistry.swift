//
//  MetalMapObjectRegistry.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

#if !os(visionOS)

import RagnarokModels
import simd

@MainActor final class MetalMapObjectRegistry {
    private(set) var objects: [GameObjectID: MetalMapObject] = [:]

    func add(_ object: MetalMapObject) {
        objects[object.objectID] = object
    }

    func remove(objectID: GameObjectID) {
        objects.removeValue(forKey: objectID)
    }

    func object(for objectID: GameObjectID) -> MetalMapObject? {
        objects[objectID]
    }

    func nearestObject(ofType type: MapObjectType, fromPosition position: SIMD2<Int>) -> MetalMapObject? {
        objects.values
            .filter {
                $0.type == type
            }
            .min {
                distanceSquared($0.gridPosition, to: position) < distanceSquared($1.gridPosition, to: position)
            }
    }

    private func distanceSquared(_ a: SIMD2<Int>, to b: SIMD2<Int>) -> Int {
        let d = a &- b
        return d.x * d.x + d.y * d.y
    }
}

#endif
