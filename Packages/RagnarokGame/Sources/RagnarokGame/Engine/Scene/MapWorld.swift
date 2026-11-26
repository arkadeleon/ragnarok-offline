//
//  MapWorld.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/11/20.
//

import Foundation
import RagnarokCore
import RagnarokEffects
import RagnarokModels
import RagnarokRenderAssets
import RagnarokRendering
import RagnarokResources
import simd

@MainActor
final class MapWorld {
    let mapGrid: MapGrid
    let pathFinder: PathFinder

    var fog = Fog()
    var sounds: [MapSceneSound] = []

    let player: MapSceneMapObject
    var objects: [GameObjectID : MapSceneMapObject] = [:]
    var items: [GameObjectID : MapSceneDroppedItem] = [:]

    var effects: [UUID : MapSceneEffect] = [:]
    var effectInstanceIDsByOwner: [GameObjectID : Set<UUID>] = [:]
    var combatTexts: [CombatText] = []

    init(
        mapGrid: MapGrid,
        account: AccountInfo,
        character: CharacterInfo,
        playerPosition: SIMD2<Int>
    ) {
        self.mapGrid = mapGrid
        self.pathFinder = PathFinder(mapGrid: mapGrid)
        self.player = MapSceneMapObject(
            account: account,
            character: character,
            gridPosition: playerPosition,
            worldPosition: mapGrid.worldPosition(for: playerPosition),
            direction: .south,
            headDirection: .lookForward
        )
    }

    func updateObjects(atTime currentTime: TimeInterval, deltaTime: TimeInterval = 0) {
        for object in objects.values {
            object.update(atTime: currentTime, deltaTime: deltaTime, mapGrid: mapGrid)
        }
    }

    func vanishedObjectIDs(atTime currentTime: TimeInterval) -> [GameObjectID] {
        objects.compactMap { objectID, object in
            object.death?.isVanished(atTime: currentTime) == true ? objectID : nil
        }
    }

    func removeExpiredCombatTexts(atTime currentTime: TimeInterval) {
        combatTexts.removeAll { combatText in
            combatText.isExpired(atTime: currentTime)
        }
    }

    func addEffect(_ effect: MapSceneEffect) {
        effects[effect.id] = effect
        if let ownerObjectID = effect.ownerObjectID {
            effectInstanceIDsByOwner[ownerObjectID, default: []].insert(effect.id)
        }
    }

    @discardableResult
    func removeEffect(instanceID: UUID) -> MapSceneEffect? {
        guard let effect = effects.removeValue(forKey: instanceID) else {
            return nil
        }

        if let ownerObjectID = effect.ownerObjectID {
            effectInstanceIDsByOwner[ownerObjectID]?.remove(instanceID)
            if effectInstanceIDsByOwner[ownerObjectID]?.isEmpty == true {
                effectInstanceIDsByOwner.removeValue(forKey: ownerObjectID)
            }
        }

        return effect
    }

    func removeEffects(ownedBy ownerObjectID: GameObjectID, key: EffectAttachmentKey? = nil) -> [UUID] {
        guard let ownedInstanceIDs = effectInstanceIDsByOwner[ownerObjectID] else {
            return []
        }

        var removedInstanceIDs: [UUID] = []
        for instanceID in ownedInstanceIDs {
            if let key, effects[instanceID]?.attachmentKey != key {
                continue
            }
            if removeEffect(instanceID: instanceID) != nil {
                removedInstanceIDs.append(instanceID)
            }
        }
        return removedInstanceIDs
    }

    func clear(includingSounds: Bool) {
        if includingSounds {
            sounds.removeAll()
        }
        objects.removeAll()
        items.removeAll()
        effects.removeAll()
        effectInstanceIDsByOwner.removeAll()
        combatTexts.removeAll()
    }
}
