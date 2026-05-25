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

    func applySnapshot(_ state: MapSceneState)

    func showSelection(at position: SIMD2<Int>, mapGrid: MapGrid)
    func addCombatText(_ combatText: MapCombatText)
    func addEffect(_ effect: MapSceneEffect)
    func playSound(named soundName: String, on objectID: GameObjectID)
}
