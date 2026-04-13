//
//  MapObjectSnapshotPresentationComponent.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/25.
//

import RealityKit
import simd

struct MapObjectSnapshotPresentationComponent: Component {
    var logicalWorldPosition: SIMD3<Float>
    var timeline: MapObjectMovementTimeline?
    var presentation: MapObjectPresentationState
}
