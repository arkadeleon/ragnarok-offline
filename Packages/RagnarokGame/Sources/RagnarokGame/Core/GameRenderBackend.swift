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
    func addDamageEffect(_ effect: MapDamageEffect)
    func addEffect(_ effect: MapEffect)
    func playSound(named soundName: String, on objectID: GameObjectID)
}
