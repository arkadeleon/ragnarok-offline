//
//  GameRenderBackend.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/21.
//

import CoreGraphics
import Foundation
import RagnarokConstants
import RagnarokModels
import simd

public enum MapHitTestResult: Sendable {
    case mapObject(objectID: UInt32)
    case item(objectID: UInt32)
    case ground(position: SIMD2<Int>)
}

@MainActor
public protocol GameRenderBackend: AnyObject {
    var projector: (any MapProjector)? { get }

    func attach(scene: MapScene)
    func detach()

    func load(progress: Progress) async
    func unload()

    func applySnapshot(_ state: MapSceneState)

    func hitTest(at screenPoint: CGPoint) -> MapHitTestResult?
}
