//
//  MapEventHandlerProtocol.swift
//  GameCore
//
//  Created by Leon Li on 2025/7/8.
//

import Constants
import NetworkClient

@MainActor
protocol MapEventHandlerProtocol {
    func onPlayerMoved(startPosition: SIMD2<Int>, endPosition: SIMD2<Int>)

    func onItemSpawned(item: MapItem, position: SIMD2<Int>)
    func onItemVanished(objectID: UInt32)

    func onMapObjectSpawned(object: MapObject, position: SIMD2<Int>, direction: Direction, headDirection: HeadDirection)
    func onMapObjectMoved(object: MapObject, startPosition: SIMD2<Int>, endPosition: SIMD2<Int>)
    func onMapObjectStopped(objectID: UInt32, position: SIMD2<Int>)
    func onMapObjectVanished(objectID: UInt32)
    func onMapObjectStateChanged(objectID: UInt32, bodyState: StatusChangeOption1, healthState: StatusChangeOption2, effectState: StatusChangeOption)
    func onMapObjectActionPerformed(sourceObjectID: UInt32, targetObjectID: UInt32, actionType: DamageType)
}
