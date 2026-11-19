//
//  MapWorld.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/11/20.
//

import Foundation
import RagnarokCore
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
    var effectIDsByOwner: [GameObjectID : Set<UUID>] = [:]
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

    func updateObjects(atTime currentTime: TimeInterval) {
        for object in objects.values {
            object.update(atTime: currentTime, mapGrid: mapGrid)
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
            effectIDsByOwner[ownerObjectID, default: []].insert(effect.id)
        }
    }

    @discardableResult
    func removeEffect(id: UUID) -> MapSceneEffect? {
        guard let effect = effects.removeValue(forKey: id) else {
            return nil
        }

        if let ownerObjectID = effect.ownerObjectID {
            effectIDsByOwner[ownerObjectID]?.remove(id)
            if effectIDsByOwner[ownerObjectID]?.isEmpty == true {
                effectIDsByOwner.removeValue(forKey: ownerObjectID)
            }
        }

        return effect
    }

    func removeEffects(ownedBy ownerObjectID: GameObjectID, key: MapEffectAttachmentKey? = nil) -> [UUID] {
        guard let ownedEffectIDs = effectIDsByOwner[ownerObjectID] else {
            return []
        }

        var removedEffectIDs: [UUID] = []
        for effectID in ownedEffectIDs {
            if let key, effects[effectID]?.attachmentKey != key {
                continue
            }
            if removeEffect(id: effectID) != nil {
                removedEffectIDs.append(effectID)
            }
        }
        return removedEffectIDs
    }

    func clear(includingSounds: Bool) {
        if includingSounds {
            sounds.removeAll()
        }
        objects.removeAll()
        items.removeAll()
        effects.removeAll()
        effectIDsByOwner.removeAll()
        combatTexts.removeAll()
    }
}
