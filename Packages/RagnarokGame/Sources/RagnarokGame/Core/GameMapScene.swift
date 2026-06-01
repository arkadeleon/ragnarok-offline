//
//  GameMapScene.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import Foundation
import RagnarokConstants
import RagnarokModels
import RagnarokPackets
import simd

@MainActor public protocol GameMapScene: MapSceneEventHandler {
    var mapName: String { get }

    func load(progress: Progress) async
    func unload()
}

@MainActor public protocol MapSceneEventHandler {
    func onPlayerMoved(startPosition: SIMD2<Int>, endPosition: SIMD2<Int>)
    func onPlayerParameterChanged(_ packet: PACKET_ZC_PAR_CHANGE)
    func onPlayerHealthPointsRecovered(hp: Int, amount: Int)
    func onPlayerSpellPointsRecovered(sp: Int, amount: Int)

    func onMapObjectSpawned(object: MapObject, position: SIMD2<Int>, direction: Direction, headDirection: HeadDirection)
    func onMapObjectMoved(object: MapObject, startPosition: SIMD2<Int>, endPosition: SIMD2<Int>)
    func onMapObjectStopped(objectID: GameObjectID, position: SIMD2<Int>)
    func onMapObjectVanished(objectID: GameObjectID, type: UInt8)
    func onMapObjectResurrected(objectID: GameObjectID)
    func onMapObjectDirectionChanged(objectID: GameObjectID, direction: Direction, headDirection: HeadDirection)
    func onMapObjectSpriteChanged(_ packet: PACKET_ZC_SPRITE_CHANGE)
    func onMapObjectStateChanged(objectID: GameObjectID, bodyState: StatusChangeOption1, healthState: StatusChangeOption2, effectState: StatusChangeOption)
    func onMapObjectActionPerformed(objectAction: MapObjectAction)
    func onMapObjectSkillPerformed(_ packet: PACKET_ZC_NOTIFY_SKILL)
    func onMapObjectHealthUpdated(_ packet: PACKET_ZC_HP_INFO)

    func onItemSpawned(item: MapItem, position: SIMD2<Int>)
    func onItemVanished(objectID: GameObjectID)

    func onGroundSkillCast(_ packet: PACKET_ZC_NOTIFY_GROUNDSKILL)
}
