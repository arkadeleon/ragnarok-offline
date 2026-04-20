//
//  GameCoordinateSpaceProjecting.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/20.
//

import CoreGraphics
import simd

public enum GameHitTestResult: Sendable {
    case mapObject(objectID: GameObjectID)
    case item(objectID: GameObjectID)
    case ground(position: SIMD2<Int>)
}

@MainActor
public protocol GameCoordinateSpaceProjecting: AnyObject {

    /// Projects a point from the 3D world coordinate system of the scene to the
    /// 2D pixel coordinate system of the screen.
    func project(_ worldPoint: SIMD3<Float>) -> CGPoint?

    /// Determines the position and direction of a ray through the given point
    /// in the 2D space of the screen.
    func ray(through screenPoint: CGPoint) -> (origin: SIMD3<Float>, direction: SIMD3<Float>)?

    /// Searches for objects corresponding to a point on the screen.
    func hitTest(_ screenPoint: CGPoint) -> GameHitTestResult?
}

extension GameCoordinateSpaceProjecting {
    func groundHit(origin: SIMD3<Float>, direction: SIMD3<Float>, mapGrid: MapGrid) -> GameHitTestResult? {
        for i in 0..<200 {
            let point = origin + direction * Float(i)

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
