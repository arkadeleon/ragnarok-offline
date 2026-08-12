//
//  GameCoordinateSpaceProjecting.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/20.
//

import CoreGraphics
import RagnarokRendering
import simd

public enum GameHitTestResult: Sendable {
    case mapObject(objectID: GameObjectID)
    case mapItem(objectID: GameObjectID)
    case ground(position: SIMD2<Int>)
}

@MainActor
public protocol GameCoordinateSpaceProjecting {
    /// Searches for objects along a ray through the world.
    func hitTest(_ ray: Ray) -> GameHitTestResult?
}

extension GameCoordinateSpaceProjecting {
    func groundHit(_ ray: Ray, mapGrid: MapGrid) -> GameHitTestResult? {
        for i in 0..<200 {
            let point = ray.point(atDistance: Float(i))

            let x = point.x
            let y = -point.z
            let position = SIMD2<Int>(Int(x), Int(y))

            guard mapGrid.contains(position) else {
                continue
            }

            let cell = mapGrid[position]
            let xr = x.truncatingRemainder(dividingBy: 1)
            let yr = y.truncatingRemainder(dividingBy: 1)

            let x1 = cell.bottomLeftAltitude + (cell.bottomRightAltitude - cell.bottomLeftAltitude) * xr
            let x2 = cell.topLeftAltitude + (cell.topRightAltitude - cell.topLeftAltitude) * xr
            let altitude = x1 + (x2 - x1) * yr

            if fabsf(altitude - point.y) < 0.5 {
                return .ground(position: position)
            }
        }

        return nil
    }
}
