//
//  MetalMapScene+EventHandler.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

#if !os(visionOS)

import Foundation
import RagnarokConstants
import RagnarokModels
import RagnarokPackets
import RagnarokSprite
import simd

extension MetalMapScene {
    func onPlayerParameterChanged(_ packet: PACKET_ZC_PAR_CHANGE) {
        guard let sp = StatusProperty(rawValue: Int(packet.varID)) else {
            return
        }

        let playerObject = objectRegistry.object(for: player.objectID) as? MetalPlayerObject

        switch sp {
        case .hp:
            let hp = Int(packet.count)
            state.overlay.gauges[player.objectID]?.hp = hp
            playerObject?.hp = hp
            renderBackend.updateObject(objectID: player.objectID)
        case .maxhp:
            let maxHp = Int(packet.count)
            state.overlay.gauges[player.objectID]?.maxHp = maxHp
            playerObject?.maxHp = maxHp
            renderBackend.updateObject(objectID: player.objectID)
        case .sp:
            let sp = Int(packet.count)
            state.overlay.gauges[player.objectID]?.sp = sp
            playerObject?.sp = sp
            renderBackend.updateObject(objectID: player.objectID)
        case .maxsp:
            let maxSp = Int(packet.count)
            state.overlay.gauges[player.objectID]?.maxSp = maxSp
            playerObject?.maxSp = maxSp
            renderBackend.updateObject(objectID: player.objectID)
        default:
            break
        }
    }

    func onPlayerHealthPointsRecovered(hp: Int, amount: Int) {
        state.overlay.gauges[player.objectID]?.hp = hp

        let playerObject = objectRegistry.object(for: player.objectID) as? MetalPlayerObject
        playerObject?.hp = hp

        renderBackend.updateObject(objectID: player.objectID)

        let combatText = MetalCombatText(
            creationTime: .now,
            target: MetalCombatText.Target(objectID: player.objectID, isPlayer: true),
            amount: amount,
            kind: .hpRecovery,
            delay: .zero
        )
        renderBackend.addCombatText(combatText)
    }

    func onPlayerSpellPointsRecovered(sp: Int, amount: Int) {
        state.overlay.gauges[player.objectID]?.sp = sp

        let playerObject = objectRegistry.object(for: player.objectID) as? MetalPlayerObject
        playerObject?.sp = sp

        renderBackend.updateObject(objectID: player.objectID)

        let combatText = MetalCombatText(
            creationTime: .now,
            target: MetalCombatText.Target(objectID: player.objectID, isPlayer: true),
            amount: amount,
            kind: .spRecovery,
            delay: .zero
        )
        renderBackend.addCombatText(combatText)
    }

    func onPlayerMoved(startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) {
        let movement = renderBackend.moveObject(
            objectID: player.objectID,
            startPosition: startPosition,
            endPosition: endPosition
        )
        let remainingDuration = movement?.remainingDuration(at: .now) ?? .zero

        if pendingArrivalAction != nil {
            arrivalTask?.cancel()
            arrivalTask = Task { @MainActor [weak self] in
                try await Task.sleep(for: remainingDuration + .milliseconds(50))
                guard let self else { return }
                if let action = pendingArrivalAction {
                    pendingArrivalAction = nil
                    action()
                }
            }
        }

        renderBackend.updateObject(objectID: player.objectID)
    }

    func onMapObjectHealthUpdated(_ packet: PACKET_ZC_HP_INFO) {
        let objectID = packet.GID
        let hp = Int(packet.HP)
        let maxHp = Int(packet.maxHP)

        if let metalObject = objectRegistry.object(for: objectID) {
            metalObject.hp = hp
            metalObject.maxHp = maxHp
            renderBackend.updateObject(objectID: objectID)
        }

        state.overlay.gauges[objectID]?.hp = hp
        state.overlay.gauges[objectID]?.maxHp = maxHp
    }

    func onMapObjectSpawned(object: MapObject, position: SIMD2<Int>, direction: Direction, headDirection: HeadDirection) {
        let metalObject = MetalMapObject.make(
            object: object,
            hp: object.hp,
            maxHp: object.maxHp,
            gridPosition: position,
            mapGrid: mapGrid,
            pathFinder: pathFinder,
            direction: SpriteDirection(direction: direction),
            headDirection: SpriteHeadDirection(headDirection: headDirection)
        )
        objectRegistry.add(metalObject)

        renderBackend.addObject(
            objectID: object.objectID,
            at: position,
            direction: SpriteDirection(direction: direction),
            headDirection: SpriteHeadDirection(headDirection: headDirection)
        )

        if object.type == .monster {
            state.overlay.gauges[object.objectID] = MapGaugeOverlay(
                id: object.objectID,
                hp: object.hp,
                maxHp: object.maxHp,
                objectType: object.type
            )
        }
    }

    func onMapObjectMoved(object: MapObject, startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) {
        let isNew = objectRegistry.object(for: object.objectID) == nil

        if isNew {
            let metalObject = MetalMapObject.make(
                object: object,
                hp: object.hp,
                maxHp: object.maxHp,
                gridPosition: endPosition,
                mapGrid: mapGrid,
                pathFinder: pathFinder,
                direction: SpriteDirection(sourcePosition: startPosition, targetPosition: endPosition),
                headDirection: .lookForward
            )
            objectRegistry.add(metalObject)

            renderBackend.addObject(
                objectID: object.objectID,
                at: startPosition,
                direction: SpriteDirection(sourcePosition: startPosition, targetPosition: endPosition),
                headDirection: .lookForward
            )

            if object.type == .monster {
                state.overlay.gauges[object.objectID] = MapGaugeOverlay(
                    id: object.objectID,
                    hp: object.hp,
                    maxHp: object.maxHp,
                    objectType: object.type
                )
            }
        } else {
            objectRegistry.object(for: object.objectID)?.gridPosition = endPosition
        }

        _ = renderBackend.moveObject(
            objectID: object.objectID,
            startPosition: startPosition,
            endPosition: endPosition
        )
    }

    func onMapObjectStopped(objectID: GameObjectID, position: SIMD2<Int>) {
        if objectRegistry.object(for: objectID) != nil {
            renderBackend.stopObject(objectID: objectID, at: position)
        }

        objectRegistry.object(for: objectID)?.gridPosition = position

        if objectID == player.objectID, let action = pendingArrivalAction {
            arrivalTask?.cancel()
            arrivalTask = nil
            pendingArrivalAction = nil
            action()
        }
    }

    func onMapObjectVanished(objectID: GameObjectID, type: UInt8) {
        switch type {
        case 1 where objectID == player.objectID:
            renderBackend.performObjectAction(
                objectID: objectID,
                action: .die,
                completion: .indefinite
            )
            state.isPlayerDead = true
            state.overlay.gauges.removeValue(forKey: objectID)
        default:
            state.overlay.gauges.removeValue(forKey: objectID)
            objectRegistry.remove(objectID: objectID)
            renderBackend.removeObject(objectID: objectID)
        }
    }

    func onMapObjectResurrected(objectID: GameObjectID) {
        renderBackend.performObjectAction(
            objectID: objectID,
            action: .idle,
            completion: .indefinite
        )
        if objectID == player.objectID {
            state.isPlayerDead = false
        }
    }

    func onMapObjectDirectionChanged(objectID: GameObjectID, direction: Direction, headDirection: HeadDirection) {
        renderBackend.turnObject(
            objectID: objectID,
            direction: SpriteDirection(direction: direction),
            headDirection: SpriteHeadDirection(headDirection: headDirection)
        )
    }

    func onMapObjectStateChanged(objectID: GameObjectID, bodyState: StatusChangeOption1, healthState: StatusChangeOption2, effectState: StatusChangeOption) {
        let isVisible = effectState != .cloak

        if let metalObject = objectRegistry.object(for: objectID) {
            metalObject.bodyState = bodyState
            metalObject.healthState = healthState
            metalObject.effectState = effectState
            renderBackend.updateObject(objectID: objectID)
        }

        if isVisible {
            if let object = objectRegistry.object(for: objectID), objectID == player.objectID || object.type == .monster {
                let sp = (object as? MetalPlayerObject)?.sp
                let maxSp = (object as? MetalPlayerObject)?.maxSp
                state.overlay.gauges[objectID] = MapGaugeOverlay(
                    id: objectID,
                    hp: object.hp,
                    maxHp: object.maxHp,
                    sp: sp,
                    maxSp: maxSp,
                    objectType: object.type
                )
            }
        } else {
            state.overlay.gauges.removeValue(forKey: objectID)
        }
    }

    func onMapObjectSpriteChanged(_ packet: PACKET_ZC_SPRITE_CHANGE) {
        let objectID = packet.AID
        guard let metalObject = objectRegistry.object(for: objectID) else {
            return
        }

        guard let look = Look(rawValue: Int(packet.type)) else {
            return
        }

        switch look {
        case .base:
            metalObject.job = Int(packet.val)
        case .hair:
            metalObject.hairStyle = Int(packet.val)
        case .weapon:
            metalObject.weapon = Int(packet.val)
            metalObject.shield = Int(packet.val2)
        case .head_bottom:
            metalObject.headBottom = Int(packet.val)
        case .head_top:
            metalObject.headTop = Int(packet.val)
        case .head_mid:
            metalObject.headMid = Int(packet.val)
        case .hair_color:
            metalObject.hairColor = Int(packet.val)
        case .clothes_color:
            metalObject.clothesColor = Int(packet.val)
        case .shield:
            metalObject.shield = Int(packet.val)
        case .robe:
            metalObject.garment = Int(packet.val)
        default:
            return
        }

        renderBackend.updateObject(objectID: objectID)
    }

    func onMapObjectActionPerformed(objectAction: MapObjectAction) {
        let now = ContinuousClock.now

        let sourceID = objectAction.sourceObjectID
        let sourceObject = objectRegistry.object(for: sourceID)

        let presentationAction: SpriteActionType = switch objectAction.type {
        case .sit_down:
            .sit
        case .stand_up:
            .idle
        case .pickup_item:
            .pickup
        case .normal, .endure, .critical, .multi_hit, .multi_hit_endure, .multi_hit_critical, .lucy_dodge:
            if let sourceObject {
                SpriteActionType.attackActionType(
                    forJobID: sourceObject.job,
                    gender: sourceObject.gender,
                    weapon: sourceObject.weapon
                )
            } else {
                .attack1
            }
        default:
            .attack1
        }

        let completion: MetalAnimationCompletion = switch presentationAction {
        case .pickup:
            .once(settledAction: .idle)
        case .sit:
            .indefinite
        case .freeze, .freeze2, .die:
            .after(.milliseconds(objectAction.sourceSpeed), settledAction: presentationAction)
        case .attack1, .attack2, .attack3, .skill:
            .after(.milliseconds(objectAction.sourceSpeed), settledAction: afterAttackAction(for: sourceObject))
        case .idle, .walk, .readyToAttack, .hurt:
            .after(.milliseconds(objectAction.sourceSpeed), settledAction: .idle)
        }

        if sourceObject != nil {
            renderBackend.performObjectAction(
                objectID: sourceID,
                action: presentationAction,
                completion: completion
            )
        }

        addCombatTexts(for: objectAction, now: now)
        playSound(for: objectAction)
    }

    func onMapObjectSkillPerformed(_ packet: PACKET_ZC_NOTIFY_SKILL) {
        let objectID = packet.AID

        let now = ContinuousClock.now

        if let sourceObject = objectRegistry.object(for: objectID) {
            let availableActionTypes = SpriteActionType.availableActionTypes(forJobID: sourceObject.job)
            let action: SpriteActionType = availableActionTypes.contains(.skill) ? .skill : .attack1
            let duration = Duration.milliseconds(Int(packet.attackMT))
            let settledAction: SpriteActionType = availableActionTypes.contains(.readyToAttack) ? .readyToAttack : .idle

            renderBackend.performObjectAction(
                objectID: objectID,
                action: action,
                completion: .after(duration, settledAction: settledAction)
            )
        }

        if packet.damage >= 0 {
            let count = Int(packet.count)
            let damage = Int(packet.damage)
            let target = MetalCombatText.Target(
                objectID: packet.targetID,
                isPlayer: objectRegistry.object(for: packet.targetID)?.type == .pc
            )

            for i in 0..<count {
                let combatText = MetalCombatText(
                    creationTime: now,
                    target: target,
                    amount: damage / count,
                    delay: .milliseconds(Int(packet.attackMT)) + .milliseconds(200 * i)
                )
                renderBackend.addCombatText(combatText)
            }
        }

        addSkillHitEffects(for: packet)
        addSkillEffects(for: packet)
    }

    func onItemSpawned(item: MapItem, position: SIMD2<Int>) {
        let metalItem = MetalMapItem(item: item, gridPosition: position)
        itemRegistry.add(metalItem)

        renderBackend.addItem(metalItem)
    }

    func onItemVanished(objectID: GameObjectID) {
        itemRegistry.remove(objectID: objectID)
        renderBackend.removeItem(objectID: objectID)
    }

    func onGroundSkillCast(_ packet: PACKET_ZC_NOTIFY_GROUNDSKILL) {
        guard let skillID = SkillID(rawValue: Int(packet.SKID)) else {
            return
        }

        let position = SIMD2(Int(packet.xPos), Int(packet.yPos))
        guard mapGrid.contains(position) else {
            return
        }

        let now = ContinuousClock.now
        for effectID in SkillEffectTable.effectIDs(for: skillID) {
            addEffects(
                forEffectID: effectID,
                creationTime: now,
                gridPosition: position,
                attachedObjectID: nil,
                delay: .zero
            )
        }
    }
}

extension MetalMapScene {
    private func afterAttackAction(for object: MetalMapObject?) -> SpriteActionType {
        guard let object else {
            return .idle
        }

        let availableActionTypes = SpriteActionType.availableActionTypes(forJobID: object.job)
        return availableActionTypes.contains(.readyToAttack) ? .readyToAttack : .idle
    }

    private func addCombatTexts(for objectAction: MapObjectAction, now: ContinuousClock.Instant) {
        let target = MetalCombatText.Target(
            objectID: objectAction.targetObjectID,
            isPlayer: objectRegistry.object(for: objectAction.targetObjectID)?.type == .pc
        )

        switch objectAction.type {
        case .normal, .endure, .critical:
            let combatText = MetalCombatText(
                creationTime: now,
                target: target,
                amount: objectAction.damage,
                delay: .milliseconds(objectAction.sourceSpeed)
            )
            renderBackend.addCombatText(combatText)

            if objectAction.damage2 > 0 {
                let combatText2 = MetalCombatText(
                    creationTime: now,
                    target: target,
                    amount: objectAction.damage2,
                    delay: .milliseconds(objectAction.sourceSpeed) + .milliseconds(200 * 1.75)
                )
                renderBackend.addCombatText(combatText2)
            }
        case .multi_hit, .multi_hit_endure, .multi_hit_critical:
            let count = objectAction.damage > 1 ? 2 : 1
            if count == 2 {
                let combatText = MetalCombatText(
                    creationTime: now,
                    target: target,
                    amount: objectAction.damage / count,
                    delay: .milliseconds(objectAction.sourceSpeed)
                )
                renderBackend.addCombatText(combatText)
            }
            if objectAction.damage2 > 0 {
                let combatText = MetalCombatText(
                    creationTime: now,
                    target: target,
                    amount: objectAction.damage / count,
                    delay: .milliseconds(objectAction.sourceSpeed) + .milliseconds(200 / 2)
                )
                renderBackend.addCombatText(combatText)

                let combatText2 = MetalCombatText(
                    creationTime: now,
                    target: target,
                    amount: objectAction.damage2,
                    delay: .milliseconds(objectAction.sourceSpeed) + .milliseconds(200 * 1.75)
                )
                renderBackend.addCombatText(combatText2)
            } else {
                let combatText = MetalCombatText(
                    creationTime: now,
                    target: target,
                    amount: objectAction.damage / count,
                    delay: .milliseconds(objectAction.sourceSpeed) + .milliseconds(200)
                )
                renderBackend.addCombatText(combatText)
            }
        default:
            break
        }
    }

    private func addSkillHitEffects(for packet: PACKET_ZC_NOTIFY_SKILL) {
        guard packet.damage > 0,
              let skillID = SkillID(rawValue: Int(packet.SKID)),
              let targetPosition = renderBackend.gridPosition(for: packet.targetID) else {
            return
        }

        let now = ContinuousClock.now
        let count = max(1, Int(packet.count))
        for hitEffectID in SkillEffectTable.hitEffectIDs(for: skillID) {
            for i in 0..<count {
                addEffects(
                    forEffectID: hitEffectID,
                    creationTime: now,
                    gridPosition: targetPosition,
                    attachedObjectID: packet.targetID,
                    delay: .milliseconds(Int(packet.attackMT)) + .milliseconds(200 * i)
                )
            }
        }
    }

    private func addSkillEffects(for packet: PACKET_ZC_NOTIFY_SKILL) {
        guard let skillID = SkillID(rawValue: Int(packet.SKID)),
              objectRegistry.object(for: packet.AID) != nil,
              objectRegistry.object(for: packet.targetID) != nil,
              let targetPosition = renderBackend.gridPosition(for: packet.targetID),
              let damageType = DamageType(rawValue: Int(packet.action)),
              damageType != .splash, damageType != .splash_endure else {
            return
        }

        let now = ContinuousClock.now
        for effectID in SkillEffectTable.effectIDs(for: skillID) {
            addEffects(
                forEffectID: effectID,
                creationTime: now,
                gridPosition: targetPosition,
                attachedObjectID: packet.targetID,
                delay: .milliseconds(Int(packet.attackMT))
            )
        }
    }

    private func addEffects(
        forEffectID effectID: Int,
        creationTime: ContinuousClock.Instant,
        gridPosition: SIMD2<Int>,
        attachedObjectID: GameObjectID?,
        delay: Duration
    ) {
        let definitions = EffectTable.definitions(forEffectID: effectID)
        for definition in definitions {
            let effect = MetalSkillEffect(
                effectID: effectID,
                effectDefinition: definition.resolved(),
                creationTime: creationTime,
                gridPosition: gridPosition,
                attachedObjectID: attachedObjectID,
                delay: delay
            )
            renderBackend.addEffect(effect)
        }
    }

    private func playSound(for objectAction: MapObjectAction) {
        let isAttackAction = switch objectAction.type {
        case .normal, .endure, .critical, .multi_hit, .multi_hit_endure, .multi_hit_critical, .lucy_dodge:
            true
        default:
            false
        }

        guard isAttackAction else {
            return
        }

        let sourceObject = objectRegistry.object(for: objectAction.sourceObjectID)
        let targetObject = objectRegistry.object(for: objectAction.targetObjectID)

        if let sourceObject, SpriteJob(rawValue: sourceObject.job).isPlayer {
            let weaponType = WeaponType(rawValue: sourceObject.weapon) ?? .w_fist
            let soundName = WeaponSoundTable.attackSoundNames(for: weaponType).randomElement()
            if let soundName {
                renderBackend.playSound(named: soundName, on: objectAction.sourceObjectID)
            }
        }

        if let targetObject, objectAction.damage > 0 {
            let targetJob = SpriteJob(rawValue: targetObject.job)

            let hitSoundName: String?
            if targetJob.isPlayer {
                hitSoundName = JobHitSoundTable.hitSoundNames(forJob: targetObject.job).randomElement()
            } else if let sourceObject, SpriteJob(rawValue: sourceObject.job).isPlayer {
                let weaponType = WeaponType(rawValue: sourceObject.weapon) ?? .w_fist
                let weaponHitSoundName = WeaponHitSoundTable.hitSoundNames(for: weaponType).randomElement()
                hitSoundName = weaponHitSoundName ?? JobHitSoundTable.hitSoundNames(forJob: targetObject.job).randomElement()
            } else {
                hitSoundName = JobHitSoundTable.hitSoundNames(forJob: targetObject.job).randomElement()
            }

            if let hitSoundName {
                Task { @MainActor [weak self] in
                    try? await Task.sleep(for: .milliseconds(objectAction.sourceSpeed))
                    guard let self else { return }
                    renderBackend.playSound(named: hitSoundName, on: objectAction.targetObjectID)
                }
            }
        }
    }
}

#endif
