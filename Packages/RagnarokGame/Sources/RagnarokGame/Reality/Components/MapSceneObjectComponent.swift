//
//  MapSceneObjectComponent.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/4/2.
//

import RealityKit
import simd

struct MapSceneObjectComponent: Component {
    var object: MapSceneObject
    var gridPosition: SIMD2<Int>
    var logicalWorldPosition: SIMD3<Float>
    var movement: MapObjectMovementState? = nil
    var animation: MapObjectAnimationState = .defaultAnimation
}
