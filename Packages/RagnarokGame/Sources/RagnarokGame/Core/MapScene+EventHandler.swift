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
            applySnapshot()
        case .maxhp:
            let maxHp = Int(packet.count)
            state.player.maxHp = maxHp
            state.overlay.gauges[player.objectID]?.maxHp = maxHp
            applySnapshot()
        case .sp:
            let sp = Int(packet.count)
            state.player.sp = sp
            state.overlay.gauges[player.objectID]?.sp = sp
            applySnapshot()
        case .maxsp:
            let maxSp = Int(packet.count)
            state.player.maxSp = maxSp
            state.overlay.gauges[player.objectID]?.maxSp = maxSp
            applySnapshot()
        default:
            break
        }
    }

    func onPlayerHealthPointsRecovered(hp: Int, amount: Int) {
        state.player.hp = hp
        state.overlay.gauges[player.objectID]?.hp = hp

        applySnapshot()

        let combatText = MapCombatText(
            creationTime: .now,
            target: MapCombatText.Target(id: player.objectID, isPlayer: true),
            amount: amount,
            kind: .hpRecovery,
            delay: .zero
        )
        renderBackend.addCombatText(combatText)
    }

    func onPlayerSpellPointsRecovered(sp: Int, amount: Int) {
        state.player.sp = sp
        state.overlay.gauges[player.objectID]?.sp = sp

        applySnapshot()

        let combatText = MapCombatText(
            creationTime: .now,
            target: MapCombatText.Target(id: player.objectID, isPlayer: true),
            amount: amount,
            kind: .spRecovery,
            delay: .zero
        )
        renderBackend.addCombatText(combatText)
    }

    func onPlayerMoved(startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) {
        let now = ContinuousClock.now

        let movementPlanner = MapObjectMovementPlanner(pathFinder: pathFinder)
        let movement = movementPlanner.replan(
            existingMovement: state.player.movement,
            existingSpeed: state.player.speed,
            incomingStartPosition: startPosition,
            incomingEndPosition: endPosition,
            incomingSpeed: state.player.speed,
            at: now
        )
        let remainingDuration = movement.remainingDuration(at: now)
        let direction = movement.finalDirection

        state.player.gridPosition = endPosition
        state.player.movement = movement
        state.player.presentation = MapObjectPresentationState(
            action: .walk,
            direction: direction,
            headDirection: state.player.presentation.headDirection,
            startTime: now,
            completion: .after(remainingDuration, settledAction: .idle)
        )

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

        applySnapshot()
    }

    func onMapObjectHealthUpdated(_ packet: PACKET_ZC_HP_INFO) {
        let objectID = packet.GID
        let hp = Int(packet.HP)
        let maxHp = Int(packet.maxHP)

        if var objectState = state.objects[objectID] {
            objectState.hp = hp
            objectState.maxHp = maxHp
            state.objects[objectID] = objectState
        }
        state.overlay.gauges[objectID]?.hp = hp
        state.overlay.gauges[objectID]?.maxHp = maxHp

        applySnapshot()
    }

    func onMapObjectSpawned(object: MapObject, position: SIMD2<Int>, direction: Direction, headDirection: HeadDirection) {
        state.objects[object.objectID] = MapObjectState(
            id: object.objectID,
            object: object,
            gridPosition: position,
            hp: object.hp,
            maxHp: object.maxHp,
            presentation: MapObjectPresentationState(
                action: .idle,
                direction: SpriteDirection(direction: direction),
                headDirection: SpriteHeadDirection(headDirection: headDirection),
                startTime: .now,
                completion: .indefinite
            )
        )

        if object.type == .monster {
            state.overlay.gauges[object.objectID] = MapGaugeOverlay(
                id: object.objectID,
                hp: object.hp,
                maxHp: object.maxHp,
                objectType: object.type
            )
        }

        applySnapshot()
    }

    func onMapObjectMoved(object: MapObject, startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) {
        let now = ContinuousClock.now
        let existingObjectState = state.objects[object.objectID]

        let movementPlanner = MapObjectMovementPlanner(pathFinder: pathFinder)
        let movement = movementPlanner.replan(
            existingMovement: existingObjectState?.movement,
            existingSpeed: existingObjectState?.speed,
            incomingStartPosition: startPosition,
            incomingEndPosition: endPosition,
            incomingSpeed: object.speed,
            at: now
        )
        let remainingDuration = movement.remainingDuration(at: now)
        let direction = movement.finalDirection

        if var objectState = state.objects[object.objectID] {
            let presentation = MapObjectPresentationState(
                action: .walk,
                direction: direction,
                headDirection: objectState.presentation.headDirection,
                startTime: now,
                completion: .after(remainingDuration, settledAction: .idle)
            )
            objectState.gridPosition = endPosition
            objectState.movement = movement
            objectState.presentation = presentation
            state.objects[object.objectID] = objectState
        } else {
            let presentation = MapObjectPresentationState(
                action: .walk,
                direction: direction,
                headDirection: .lookForward,
                startTime: now,
                completion: .after(remainingDuration, settledAction: .idle)
            )
            state.objects[object.objectID] = MapObjectState(
                id: object.objectID,
                object: object,
                gridPosition: endPosition,
                hp: object.hp,
                maxHp: object.maxHp,
                movement: movement,
                presentation: presentation
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

        applySnapshot()
    }

    func onMapObjectStopped(objectID: GameObjectID, position: SIMD2<Int>) {
        let now = ContinuousClock.now

        if var objectState = state.objects[objectID] {
            objectState.gridPosition = position
            objectState.movement = nil
            objectState.presentation = MapObjectPresentationState(
                action: .idle,
                direction: objectState.presentation.direction,
                headDirection: objectState.presentation.headDirection,
                startTime: now,
                completion: .indefinite
            )
            state.objects[objectID] = objectState
        }

        if objectID == state.playerID, let action = pendingArrivalAction {
            arrivalTask?.cancel()
            arrivalTask = nil
            pendingArrivalAction = nil
            action()
        }

        applySnapshot()
    }

    func onMapObjectVanished(objectID: GameObjectID) {
        if objectID == state.playerID {
            // TODO: player death
        } else {
            state.objects.removeValue(forKey: objectID)
        }
        state.overlay.gauges.removeValue(forKey: objectID)

        applySnapshot()
    }

    func onMapObjectDirectionChanged(objectID: GameObjectID, direction: Direction, headDirection: HeadDirection) {
        if var objectState = state.objects[objectID] {
            objectState.presentation.direction = SpriteDirection(direction: direction)
            objectState.presentation.headDirection = SpriteHeadDirection(headDirection: headDirection)
            state.objects[objectID] = objectState
        }

        applySnapshot()
    }

    func onMapObjectStateChanged(objectID: GameObjectID, bodyState: StatusChangeOption1, healthState: StatusChangeOption2, effectState: StatusChangeOption) {
        let isVisible = effectState != .cloak

        if var objectState = state.objects[objectID] {
            objectState.bodyState = bodyState
            objectState.healthState = healthState
            objectState.effectState = effectState
            state.objects[objectID] = objectState
        }

        if isVisible {
            if let objectState = state.objects[objectID], objectID == state.playerID || objectState.type == .monster {
                state.overlay.gauges[objectID] = MapGaugeOverlay(
                    id: objectID,
                    hp: objectState.hp,
                    maxHp: objectState.maxHp,
                    sp: objectState.sp,
                    maxSp: objectState.maxSp,
                    objectType: objectState.type
                )
            }
        } else {
            state.overlay.gauges.removeValue(forKey: objectID)
        }

        applySnapshot()
    }

    func onMapObjectSpriteChanged(_ packet: PACKET_ZC_SPRITE_CHANGE) {
        let objectID = packet.AID
        guard var objectState = state.objects[objectID] else {
            return
        }

        guard let look = Look(rawValue: Int(packet.type)) else {
            return
        }

        switch look {
        case .base:
            objectState.job = Int(packet.val)
        case .hair:
            objectState.hairStyle = Int(packet.val)
        case .weapon:
            objectState.weapon = Int(packet.val)
            objectState.shield = Int(packet.val2)
        case .head_bottom:
            objectState.headBottom = Int(packet.val)
        case .head_top:
            objectState.headTop = Int(packet.val)
        case .head_mid:
            objectState.headMid = Int(packet.val)
        case .hair_color:
            objectState.hairColor = Int(packet.val)
        case .clothes_color:
            objectState.clothesColor = Int(packet.val)
        case .shield:
            objectState.shield = Int(packet.val)
        case .robe:
            objectState.garment = Int(packet.val)
        default:
            return
        }

        state.objects[objectID] = objectState
        applySnapshot()
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

        if var objectState = state.objects[sourceID] {
            objectState.presentation = MapObjectPresentationState(
                action: presentationAction,
                direction: objectState.presentation.direction,
                headDirection: objectState.presentation.headDirection,
                startTime: now,
                completion: completion
            )
            state.objects[sourceID] = objectState
        }

        applySnapshot()

        addCombatTexts(for: objectAction, now: now)
        playSound(for: objectAction)
    }

    func onMapObjectSkillPerformed(_ packet: PACKET_ZC_NOTIFY_SKILL) {
        let objectID = packet.AID

        let now = ContinuousClock.now
        let sourceState = state.objects[objectID]

        if let sourceState {
            let availableActionTypes = SpriteActionType.availableActionTypes(forJobID: sourceState.job)
            let action: SpriteActionType = availableActionTypes.contains(.skill) ? .skill : .attack1
            let duration = Duration.milliseconds(Int(packet.attackMT))
            let settledAction: SpriteActionType = availableActionTypes.contains(.readyToAttack) ? .readyToAttack : .idle

            if var objectState = state.objects[objectID] {
                objectState.presentation = MapObjectPresentationState(
                    action: action,
                    direction: objectState.presentation.direction,
                    headDirection: objectState.presentation.headDirection,
                    startTime: now,
                    completion: .after(duration, settledAction: settledAction)
                )
                state.objects[objectID] = objectState
            }
        }

        applySnapshot()

        if packet.damage >= 0 {
            let count = Int(packet.count)
            let damage = Int(packet.damage)
            let target = MapCombatText.Target(
                id: packet.targetID,
                isPlayer: state.objects[packet.targetID]?.type == .pc
            )

            for i in 0..<count {
                let combatText = MapCombatText(
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
        state.items[item.objectID] = MapItemState(
            id: item.objectID,
            item: item,
            gridPosition: position
        )

        applySnapshot()
    }

    func onItemVanished(objectID: GameObjectID) {
        state.items.removeValue(forKey: objectID)

        applySnapshot()
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
    private func afterAttackAction(for objectState: MapObjectState?) -> SpriteActionType {
        guard let objectState else {
            return .idle
        }

        let availableActionTypes = SpriteActionType.availableActionTypes(forJobID: objectState.job)
        return availableActionTypes.contains(.readyToAttack) ? .readyToAttack : .idle
    }

    private func addCombatTexts(for objectAction: MapObjectAction, now: ContinuousClock.Instant) {
        let target = MapCombatText.Target(
            id: objectAction.targetObjectID,
            isPlayer: state.objects[objectAction.targetObjectID]?.type == .pc
        )

        switch objectAction.type {
        case .normal, .endure, .critical:
            let combatText = MapCombatText(
                creationTime: now,
                target: target,
                amount: objectAction.damage,
                delay: .milliseconds(objectAction.sourceSpeed)
            )
            renderBackend.addCombatText(combatText)

            if objectAction.damage2 > 0 {
                let combatText2 = MapCombatText(
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
                let combatText = MapCombatText(
                    creationTime: now,
                    target: target,
                    amount: objectAction.damage / count,
                    delay: .milliseconds(objectAction.sourceSpeed)
                )
                renderBackend.addCombatText(combatText)
            }
            if objectAction.damage2 > 0 {
                let combatText = MapCombatText(
                    creationTime: now,
                    target: target,
                    amount: objectAction.damage / count,
                    delay: .milliseconds(objectAction.sourceSpeed) + .milliseconds(200 / 2)
                )
                renderBackend.addCombatText(combatText)

                let combatText2 = MapCombatText(
                    creationTime: now,
                    target: target,
                    amount: objectAction.damage2,
                    delay: .milliseconds(objectAction.sourceSpeed) + .milliseconds(200 * 1.75)
                )
                renderBackend.addCombatText(combatText2)
            } else {
                let combatText = MapCombatText(
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
            let effect = MapEffect(
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
