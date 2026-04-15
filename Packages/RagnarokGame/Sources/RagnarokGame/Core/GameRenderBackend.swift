//
//  GameRenderBackend.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/21.
//

import Foundation
import simd

@MainActor
public protocol GameRenderBackend: AnyObject {
    func attach(scene: MapScene)
    func detach()

    func load(progress: Progress) async
    func unload()

    func applySnapshot(_ state: MapSceneState)

    func playSound(_ filename: String, at position: SIMD2<Int>)
}

public extension GameRenderBackend {
    func playSound(_ filename: String, at position: SIMD2<Int>) {}
}
