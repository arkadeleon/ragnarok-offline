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

    func currentPlayerMovementOrigin() -> SIMD2<Int>?
    func schedulePlayerArrivalAction(within range: Int, onArrival: @escaping @MainActor () -> Void)

    func updateHealthAndSpellPoints(for objectID: UInt32, hp: Int?, maxHp: Int?, sp: Int?, maxSp: Int?) async

    func movePlayer(from startPosition: SIMD2<Int>, to endPosition: SIMD2<Int>) async
    func spawnMapObject(_ object: MapObject, position: SIMD2<Int>, direction: Direction) async
    func moveMapObject(_ object: MapObject, startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) async
    func stopMapObject(objectID: UInt32, position: SIMD2<Int>) async
    func removeMapObject(objectID: UInt32) async

    func setVisibility(forObjectID objectID: UInt32, isVisible: Bool) async
    func performMapObjectAction(_ objectAction: MapObjectAction) async
    func performSkill(_ packet: PACKET_ZC_NOTIFY_SKILL) async

    func spawnItem(_ item: MapItem, position: SIMD2<Int>) async
    func removeItem(objectID: UInt32) async
}
