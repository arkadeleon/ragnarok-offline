//
//  MapScene+EventHandler.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/20.
//

import Foundation
import RagnarokConstants
import RagnarokModels
import RagnarokPackets
import RagnarokSprite
import simd

extension MapScene {
    func onPlayerParameterChanged(_ packet: PACKET_ZC_PAR_CHANGE) {
        guard let sp = StatusProperty(rawValue: Int(packet.varID)) else {
            return
        }

        switch sp {
        case .hp:
            let hp = Int(packet.count)
            state.player.hp = hp
            state.overlay.gauges[player.objectID]?.hp = hp
            renderBackend.updateObject(state.player)
        case .maxhp:
            let maxHp = Int(packet.count)
            state.player.maxHp = maxHp
            state.overlay.gauges[player.objectID]?.maxHp = maxHp
            renderBackend.updateObject(state.player)
        case .sp:
            let sp = Int(packet.count)
            state.player.sp = sp
            state.overlay.gauges[player.objectID]?.sp = sp
            renderBackend.updateObject(state.player)
        case .maxsp:
            let maxSp = Int(packet.count)
            state.player.maxSp = maxSp
            state.overlay.gauges[player.objectID]?.maxSp = maxSp
            renderBackend.updateObject(state.player)
        default:
            break
        }
    }

    func onPlayerHealthPointsRecovered(hp: Int, amount: Int) {
        state.player.hp = hp
        state.overlay.gauges[player.objectID]?.hp = hp

        renderBackend.updateObject(state.player)

        let combatText = MapSceneCombatText(
            creationTime: .now,
            target: MapSceneCombatText.Target(objectID: player.objectID, isPlayer: true),
            amount: amount,
            kind: .hpRecovery,
            delay: .zero
        )
        renderBackend.addCombatText(combatText)
    }

    func onPlayerSpellPointsRecovered(sp: Int, amount: Int) {
        state.player.sp = sp
        state.overlay.gauges[player.objectID]?.sp = sp

        renderBackend.updateObject(state.player)

        let combatText = MapSceneCombatText(
            creationTime: .now,
            target: MapSceneCombatText.Target(objectID: player.objectID, isPlayer: true),
            amount: amount,
            kind: .spRecovery,
            delay: .zero
        )
        renderBackend.addCombatText(combatText)
    }

    func onPlayerMoved(startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) {
        let now = ContinuousClock.now

        let command = MapObjectMoveCommand(
            objectID: player.objectID,
            startPosition: startPosition,
            endPosition: endPosition,
            speed: state.player.speed,
            startedAt: now
        )
        let movement = renderBackend.moveObject(command)
        let remainingDuration = movement?.remainingDuration(at: now) ?? .zero

        state.player.gridPosition = endPosition

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

        renderBackend.updateObject(state.player)
    }

    func onMapObjectHealthUpdated(_ packet: PACKET_ZC_HP_INFO) {
        let objectID = packet.GID
        let hp = Int(packet.HP)
        let maxHp = Int(packet.maxHP)

        if var object = state.objects[objectID] {
            object.hp = hp
            object.maxHp = maxHp
            state.objects[objectID] = object
            renderBackend.updateObject(object)
        }

        state.overlay.gauges[objectID]?.hp = hp
        state.overlay.gauges[objectID]?.maxHp = maxHp
    }

    func onMapObjectSpawned(object: MapObject, position: SIMD2<Int>, direction: Direction, headDirection: HeadDirection) {
        let sceneObject = MapSceneObject(
            object: object,
            gridPosition: position,
            hp: object.hp,
            maxHp: object.maxHp
        )
        state.objects[object.objectID] = sceneObject
        renderBackend.addObject(
            sceneObject,
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
        let now = ContinuousClock.now
        let isNew = state.objects[object.objectID] == nil

        if isNew {
            let sceneObject = MapSceneObject(
                object: object,
                gridPosition: startPosition,
                hp: object.hp,
                maxHp: object.maxHp
            )
            state.objects[object.objectID] = sceneObject
            renderBackend.addObject(
                sceneObject,
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
        }

        let command = MapObjectMoveCommand(
            objectID: object.objectID,
            startPosition: startPosition,
            endPosition: endPosition,
            speed: object.speed,
            startedAt: now
        )
        _ = renderBackend.moveObject(command)

        if var updated = state.objects[object.objectID] {
            updated.gridPosition = endPosition
            state.objects[object.objectID] = updated
            renderBackend.updateObject(updated)
        }
    }

    func onMapObjectStopped(objectID: GameObjectID, position: SIMD2<Int>) {
        if var object = state.objects[objectID] {
            object.gridPosition = position
            state.objects[objectID] = object
            renderBackend.stopObject(objectID: objectID, at: position)
        }

        if objectID == state.playerID, let action = pendingArrivalAction {
            arrivalTask?.cancel()
            arrivalTask = nil
            pendingArrivalAction = nil
            action()
        }
    }

    func onMapObjectVanished(objectID: GameObjectID, type: UInt8) {
        switch type {
        case 1 where objectID == state.playerID:
            renderBackend.performObjectAction(
                MapObjectPresentationCommand(
                    objectID: objectID,
                    action: .die,
                    startTime: .now,
                    completion: .indefinite
                )
            )
            state.isPlayerDead = true
            state.overlay.gauges.removeValue(forKey: objectID)
        default:
            state.objects.removeValue(forKey: objectID)
            state.overlay.gauges.removeValue(forKey: objectID)
            renderBackend.removeObject(objectID: objectID)
        }
    }

    func onMapObjectResurrected(objectID: GameObjectID) {
        renderBackend.performObjectAction(
            MapObjectPresentationCommand(
                objectID: objectID,
                action: .idle,
                startTime: .now,
                completion: .indefinite
            )
        )
        if objectID == state.playerID {
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

        if var object = state.objects[objectID] {
            object.bodyState = bodyState
            object.healthState = healthState
            object.effectState = effectState
            state.objects[objectID] = object
            renderBackend.updateObject(object)
        }

        if isVisible {
            if let object = state.objects[objectID], objectID == state.playerID || object.type == .monster {
                state.overlay.gauges[objectID] = MapGaugeOverlay(
                    id: objectID,
                    hp: object.hp,
                    maxHp: object.maxHp,
                    sp: object.sp,
                    maxSp: object.maxSp,
                    objectType: object.type
                )
            }
        } else {
            state.overlay.gauges.removeValue(forKey: objectID)
        }
    }

    func onMapObjectSpriteChanged(_ packet: PACKET_ZC_SPRITE_CHANGE) {
        let objectID = packet.AID
        guard var object = state.objects[objectID] else {
            return
        }

        guard let look = Look(rawValue: Int(packet.type)) else {
            return
        }

        switch look {
        case .base:
            object.job = Int(packet.val)
        case .hair:
            object.hairStyle = Int(packet.val)
        case .weapon:
            object.weapon = Int(packet.val)
            object.shield = Int(packet.val2)
        case .head_bottom:
            object.headBottom = Int(packet.val)
        case .head_top:
            object.headTop = Int(packet.val)
        case .head_mid:
            object.headMid = Int(packet.val)
        case .hair_color:
            object.hairColor = Int(packet.val)
        case .clothes_color:
            object.clothesColor = Int(packet.val)
        case .shield:
            object.shield = Int(packet.val)
        case .robe:
            object.garment = Int(packet.val)
        default:
            return
        }

        state.objects[objectID] = object
        renderBackend.updateObject(object)
    }

    func onMapObjectActionPerformed(objectAction: MapObjectAction) {
        let now = ContinuousClock.now

        let sourceID = objectAction.sourceObjectID
        let sourceState = state.objects[sourceID]

        let presentationAction: SpriteActionType = switch objectAction.type {
        case .sit_down:
            .sit
        case .stand_up:
            .idle
        case .pickup_item:
            .pickup
        case .normal, .endure, .critical, .multi_hit, .multi_hit_endure, .multi_hit_critical, .lucy_dodge:
            if let sourceState {
                SpriteActionType.attackActionType(
                    forJobID: sourceState.job,
                    gender: sourceState.gender,
                    weapon: sourceState.weapon
                )
            } else {
                .attack1
            }
        default:
            .attack1
        }

        let completion: MapObjectAnimationCompletion = switch presentationAction {
        case .pickup:
            .once(settledAction: .idle)
        case .sit:
            .indefinite
        case .freeze, .freeze2, .die:
            .after(.milliseconds(objectAction.sourceSpeed), settledAction: presentationAction)
        case .attack1, .attack2, .attack3, .skill:
            .after(.milliseconds(objectAction.sourceSpeed), settledAction: afterAttackAction(for: sourceState))
        case .idle, .walk, .readyToAttack, .hurt:
            .after(.milliseconds(objectAction.sourceSpeed), settledAction: .idle)
        }

        if state.objects[sourceID] != nil {
            renderBackend.performObjectAction(
                MapObjectPresentationCommand(
                    objectID: sourceID,
                    action: presentationAction,
                    startTime: now,
                    completion: completion
                )
            )
        }

        addCombatTexts(for: objectAction, now: now)
        playSound(for: objectAction)
    }

    func onMapObjectSkillPerformed(_ packet: PACKET_ZC_NOTIFY_SKILL) {
        let objectID = packet.AID

        let now = ContinuousClock.now

        if let sourceObject = state.objects[objectID] {
            let availableActionTypes = SpriteActionType.availableActionTypes(forJobID: sourceObject.job)
            let action: SpriteActionType = availableActionTypes.contains(.skill) ? .skill : .attack1
            let duration = Duration.milliseconds(Int(packet.attackMT))
            let settledAction: SpriteActionType = availableActionTypes.contains(.readyToAttack) ? .readyToAttack : .idle

            renderBackend.performObjectAction(
                MapObjectPresentationCommand(
                    objectID: objectID,
                    action: action,
                    startTime: now,
                    completion: .after(duration, settledAction: settledAction)
                )
            )
        }

        if packet.damage >= 0 {
            let count = Int(packet.count)
            let damage = Int(packet.damage)
            let target = MapSceneCombatText.Target(
                objectID: packet.targetID,
                isPlayer: state.objects[packet.targetID]?.type == .pc
            )

            for i in 0..<count {
                let combatText = MapSceneCombatText(
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
        state.items[item.objectID] = MapSceneItem(
            item: item,
            gridPosition: position
        )

        renderBackend.addItem(state.items[item.objectID]!)
    }

    func onItemVanished(objectID: GameObjectID) {
        state.items.removeValue(forKey: objectID)

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

extension MapScene {
    private func afterAttackAction(for object: MapSceneObject?) -> SpriteActionType {
        guard let object else {
            return .idle
        }

        let availableActionTypes = SpriteActionType.availableActionTypes(forJobID: object.job)
        return availableActionTypes.contains(.readyToAttack) ? .readyToAttack : .idle
    }

    private func addCombatTexts(for objectAction: MapObjectAction, now: ContinuousClock.Instant) {
        let target = MapSceneCombatText.Target(
            objectID: objectAction.targetObjectID,
            isPlayer: state.objects[objectAction.targetObjectID]?.type == .pc
        )

        switch objectAction.type {
        case .normal, .endure, .critical:
            let combatText = MapSceneCombatText(
                creationTime: now,
                target: target,
                amount: objectAction.damage,
                delay: .milliseconds(objectAction.sourceSpeed)
            )
            renderBackend.addCombatText(combatText)

            if objectAction.damage2 > 0 {
                let combatText2 = MapSceneCombatText(
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
                let combatText = MapSceneCombatText(
                    creationTime: now,
                    target: target,
                    amount: objectAction.damage / count,
                    delay: .milliseconds(objectAction.sourceSpeed)
                )
                renderBackend.addCombatText(combatText)
            }
            if objectAction.damage2 > 0 {
                let combatText = MapSceneCombatText(
                    creationTime: now,
                    target: target,
                    amount: objectAction.damage / count,
                    delay: .milliseconds(objectAction.sourceSpeed) + .milliseconds(200 / 2)
                )
                renderBackend.addCombatText(combatText)

                let combatText2 = MapSceneCombatText(
                    creationTime: now,
                    target: target,
                    amount: objectAction.damage2,
                    delay: .milliseconds(objectAction.sourceSpeed) + .milliseconds(200 * 1.75)
                )
                renderBackend.addCombatText(combatText2)
            } else {
                let combatText = MapSceneCombatText(
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
              let targetPosition = state.objects[packet.targetID]?.gridPosition else {
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
              let _ = state.objects[packet.AID],
              let target = state.objects[packet.targetID],
              let damageType = DamageType(rawValue: Int(packet.action)),
              damageType != .splash, damageType != .splash_endure else {
            return
        }

        let now = ContinuousClock.now
        for effectID in SkillEffectTable.effectIDs(for: skillID) {
            addEffects(
                forEffectID: effectID,
                creationTime: now,
                gridPosition: target.gridPosition,
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
            let effect = MapSceneEffect(
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

        let sourceState = state.objects[objectAction.sourceObjectID]
        let targetState = state.objects[objectAction.targetObjectID]

        if let sourceState, SpriteJob(rawValue: sourceState.job).isPlayer {
            let weaponType = WeaponType(rawValue: sourceState.weapon) ?? .w_fist
            let soundName = WeaponSoundTable.attackSoundNames(for: weaponType).randomElement()
            if let soundName {
                renderBackend.playSound(named: soundName, on: objectAction.sourceObjectID)
            }
        }

        if let targetState, objectAction.damage > 0 {
            let targetJob = SpriteJob(rawValue: targetState.job)

            let hitSoundName: String?
            if targetJob.isPlayer {
                hitSoundName = JobHitSoundTable.hitSoundNames(forJob: targetState.job).randomElement()
            } else if let sourceState, SpriteJob(rawValue: sourceState.job).isPlayer {
                let weaponType = WeaponType(rawValue: sourceState.weapon) ?? .w_fist
                let weaponHitSoundName = WeaponHitSoundTable.hitSoundNames(for: weaponType).randomElement()
                hitSoundName = weaponHitSoundName ?? JobHitSoundTable.hitSoundNames(forJob: targetState.job).randomElement()
            } else {
                hitSoundName = JobHitSoundTable.hitSoundNames(forJob: targetState.job).randomElement()
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
