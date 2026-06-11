//
//  GameMapScene.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import Foundation
import RagnarokConstants
import RagnarokModels
import simd

@MainActor public protocol GameMapScene: MapSceneEventHandler {
    var mapName: String { get }

    func load(progress: Progress) async throws
    func unload()
}

@MainActor public protocol MapSceneEventHandler {
    func onPlayerMoved(startPosition: SIMD2<Int>, endPosition: SIMD2<Int>)
    func onPlayerStatusChanged(property: StatusProperty, value: Int)
    func onPlayerHealthPointsRecovered(recovered: Int, current: Int)
    func onPlayerSpellPointsRecovered(recovered: Int, current: Int)

    func onMapObjectSpawned(object: MapObject, position: SIMD2<Int>, direction: Direction, headDirection: HeadDirection)
    func onMapObjectMoved(object: MapObject, startPosition: SIMD2<Int>, endPosition: SIMD2<Int>)
    func onMapObjectStopped(objectID: GameObjectID, position: SIMD2<Int>)
    func onMapObjectVanished(objectID: GameObjectID, type: UnitClearType)
    func onMapObjectResurrected(objectID: GameObjectID)
    func onMapObjectDirectionChanged(objectID: GameObjectID, direction: Direction, headDirection: HeadDirection)
    func onMapObjectSpriteChanged(objectID: GameObjectID, look: Look, value: Int, value2: Int)
    func onMapObjectStateChanged(objectID: GameObjectID, bodyState: StatusChangeOption1, healthState: StatusChangeOption2, effectState: StatusChangeOption)
    func onMapObjectActionPerformed(objectAction: MapObjectAction)
    func onMapObjectSkillPerformed(objectSkill: MapObjectSkill)
    func onMapObjectHealthUpdated(objectID: GameObjectID, hp: Int, maxHp: Int)

    func onItemSpawned(item: MapItem, position: SIMD2<Int>)
    func onItemVanished(objectID: GameObjectID)

    func onGroundSkillCast(skillID: SkillID, position: SIMD2<Int>)
}
