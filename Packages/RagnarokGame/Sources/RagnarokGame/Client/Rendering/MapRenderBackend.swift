//
//  MapRenderBackend.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/21.
//

import CoreGraphics
import Foundation
import RagnarokConstants
import RagnarokModels
import RagnarokPackets
import simd

public enum MapHitTestResult: Sendable {
    case mapObject(objectID: UInt32)
    case item(objectID: UInt32)
    case ground(position: SIMD2<Int>)
}

@MainActor
public protocol MapRenderBackend: AnyObject {
    var projector: (any MapProjector)? { get }

    func attach(scene: MapScene)
    func detach()

    func applySnapshot(_ state: MapSceneState)

    func hitTest(at screenPoint: CGPoint) -> MapHitTestResult?
}

@MainActor
protocol MapSceneRuntimeBackend: MapRenderBackend {
    func load(progress: Progress) async
    func unload()

    func performMapObjectAction(_ objectAction: MapObjectAction) async
    func performSkill(_ packet: PACKET_ZC_NOTIFY_SKILL) async
}
