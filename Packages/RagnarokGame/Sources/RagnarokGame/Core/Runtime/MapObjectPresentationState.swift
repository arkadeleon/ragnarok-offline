//
//  MapObjectPresentationState.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/24.
//

import RagnarokSprite

public struct MapObjectPresentationState: Sendable {
    public var action: SpriteActionType
    public var direction: SpriteDirection
    public var headDirection: SpriteHeadDirection
    public var startTime: ContinuousClock.Instant
    public var completion: MapObjectAnimationCompletion

    static var defaultPresentation: MapObjectPresentationState {
        MapObjectPresentationState(
            action: .idle,
            direction: .south,
            headDirection: .lookForward,
            startTime: .now,
            completion: .indefinite
        )
    }
}
