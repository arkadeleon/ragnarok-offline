//
//  MapSceneState.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/20.
//

import Observation
import simd

@MainActor
@Observable
public final class MapSceneState {
    public let playerID: GameObjectID
    public var isPlayerDead = false

    public var objects: [GameObjectID : MapSceneObject]
    public var items: [GameObjectID : MapSceneItem] = [:]
    public let overlay = MapOverlayState()

    public var player: MapSceneObject {
        get {
            guard let player = objects[playerID] else {
                preconditionFailure("MapSceneState.objects must contain the player.")
            }
            return player
        }
        set {
            precondition(newValue.objectID == playerID, "MapSceneState.player must keep the original player ID.")
            objects[playerID] = newValue
        }
    }

    public init(player: MapSceneObject) {
        self.playerID = player.objectID
        self.objects = [player.objectID: player]
    }
}
