//
//  MapWorldContext.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/11/20.
//

import Foundation
import RagnarokCore

@MainActor
protocol MapWorldContext: AnyObject {
    func terrainHeight(atWorldX x: Float, worldZ: Float) -> Float
    func object(for id: GameObjectID) -> MapSceneMapObject?
    func playSoundEffect(named name: String, after delay: TimeInterval)
    func shakeCamera(amplitude: Float, duration: TimeInterval, frequency: Float)
    func spawnEffect(_ effect: MapSceneEffect)
}
