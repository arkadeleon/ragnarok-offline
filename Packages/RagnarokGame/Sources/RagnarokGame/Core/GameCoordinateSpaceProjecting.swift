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
