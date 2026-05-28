//
//  MapObjectPresentationSampler.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/25.
//

import RagnarokSprite
import simd

struct MapObjectPresentationSampler {
    struct PresentationSample {
        var worldPosition: SIMD3<Float>
        var animation: MapObjectAnimationState
    }

    func sample(
        timeline: MapObjectMovementTimeline?,
        headDirection: SpriteHeadDirection,
        now: ContinuousClock.Instant
    ) -> PresentationSample? {
        guard let movementSample = timeline?.sample(at: now),
              movementSample.isMoving else {
            return nil
        }

        let animation = MapObjectAnimationState(
            action: .walk,
            direction: movementSample.direction,
            headDirection: headDirection,
            startTime: now - movementSample.totalElapsed,
            elapsedTime: movementSample.totalElapsed,
            completion: .indefinite
        )
        let sample = PresentationSample(
            worldPosition: movementSample.worldPosition,
            animation: animation
        )
        return sample
    }
}
