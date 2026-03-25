//
//  MapObjectPresentationTimeline.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/25.
//

import RagnarokSprite
import simd

struct MapObjectPresentationTimeline {
    var gridPath: [SIMD2<Int>]
    var worldPath: [SIMD3<Float>]
    var stepDurations: [Duration]
    var startTime: ContinuousClock.Instant
    var duration: Duration
    var direction: CharacterDirection
}
