//
//  GameRenderBackend.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/21.
//

import Foundation

@MainActor
public protocol GameRenderBackend: AnyObject {
    func attach(scene: MapScene)
    func detach()

    func load(progress: Progress) async
    func unload()

    func applySnapshot(_ state: MapSceneState)

    func playSound(named soundName: String, on objectID: GameObjectID)
}
