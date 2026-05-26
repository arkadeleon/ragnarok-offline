//
//  MapObjectPresentationCommand.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/26.
//

import RagnarokSprite

public struct MapObjectPresentationCommand: Sendable {
    public var objectID: GameObjectID
    public var action: SpriteActionType
    public var startTime: ContinuousClock.Instant
    public var completion: MapObjectAnimationCompletion

    public init(
        objectID: GameObjectID,
        action: SpriteActionType,
        startTime: ContinuousClock.Instant,
        completion: MapObjectAnimationCompletion
    ) {
        self.objectID = objectID
        self.action = action
        self.startTime = startTime
        self.completion = completion
    }
}
