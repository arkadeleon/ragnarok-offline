//
//  GameRenderBackend.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/21.
//

import Foundation
import RagnarokSprite
import simd

@MainActor
protocol GameRenderBackend: AnyObject {
    func attach(scene: MapScene)
    func detach()

    func load(progress: Progress) async
    func unload()

    func updateCamera(_ cameraState: MapCameraState)

    func addObject(_ object: MapSceneObject, direction: SpriteDirection, headDirection: SpriteHeadDirection)
    func updateObject(_ object: MapSceneObject)
    func moveObject(_ command: MapObjectMoveCommand) -> MapObjectMovementState?
    func stopObject(objectID: GameObjectID, at position: SIMD2<Int>)
    func turnObject(objectID: GameObjectID, direction: SpriteDirection, headDirection: SpriteHeadDirection)
    func performObjectAction(_ command: MapObjectPresentationCommand)
    func removeObject(objectID: GameObjectID)

    func addItem(_ item: MapSceneItem)
    func removeItem(objectID: GameObjectID)

    func presentationGridPosition(for objectID: GameObjectID) -> SIMD2<Int>?

    func showSelection(at position: SIMD2<Int>, mapGrid: MapGrid)
    func addCombatText(_ combatText: MapSceneCombatText)
    func addEffect(_ effect: MapSceneEffect)
    func playSound(named soundName: String, on objectID: GameObjectID)
}
