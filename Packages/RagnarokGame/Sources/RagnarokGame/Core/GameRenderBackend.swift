//
//  GameRenderBackend.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/21.
//

import Foundation
import simd

@MainActor
protocol GameRenderBackend: AnyObject {
    func attach(scene: MapScene)
    func detach()

    func load(progress: Progress) async
    func unload()

    func updateCamera(_ cameraState: MapCameraState)

    func addObject(_ object: MapSceneObject)
    func updateObject(_ object: MapSceneObject)
    func moveObject(_ command: MapObjectMoveCommand) -> MapObjectMovementState?
    func stopObject(objectID: GameObjectID, at position: SIMD2<Int>)
    func removeObject(objectID: GameObjectID)

    func addItem(_ item: MapSceneItem)
    func removeItem(objectID: GameObjectID)

    func presentationGridPosition(for objectID: GameObjectID) -> SIMD2<Int>?
    func presentationWorldPosition(for objectID: GameObjectID) -> SIMD3<Float>?

    func showSelection(at position: SIMD2<Int>, mapGrid: MapGrid)
    func addCombatText(_ combatText: MapSceneCombatText)
    func addEffect(_ effect: MapSceneEffect)
    func playSound(named soundName: String, on objectID: GameObjectID)
}
