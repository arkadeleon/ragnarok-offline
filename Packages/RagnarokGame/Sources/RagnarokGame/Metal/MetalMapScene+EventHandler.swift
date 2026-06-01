//
//  MetalMapScene+EventHandler.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import Foundation
import RagnarokConstants
import RagnarokModels
import RagnarokSprite
import simd

extension MetalMapScene {
    public func onPlayerStatusChanged(property: StatusProperty, value: Int) {
        let playerObject = objectRegistry.object(for: player.objectID) as? MetalPlayerObject

        switch property {
        case .hp:
            state.overlay.gauges[player.objectID]?.hp = value
            playerObject?.hp = value
            renderBackend.updateObject(objectID: player.objectID)
        case .maxhp:
            state.overlay.gauges[player.objectID]?.maxHp = value
            playerObject?.maxHp = value
            renderBackend.updateObject(objectID: player.objectID)
        case .sp:
            state.overlay.gauges[player.objectID]?.sp = value
            playerObject?.sp = value
            renderBackend.updateObject(objectID: player.objectID)
        case .maxsp:
            state.overlay.gauges[player.objectID]?.maxSp = value
            playerObject?.maxSp = value
            renderBackend.updateObject(objectID: player.objectID)
        default:
            break
        }
    }

    public func onPlayerHealthPointsRecovered(recovered: Int, current: Int) {
        state.overlay.gauges[player.objectID]?.hp = current

        let playerObject = objectRegistry.object(for: player.objectID) as? MetalPlayerObject
        playerObject?.hp = current

        renderBackend.updateObject(objectID: player.objectID)

        let combatText = MetalCombatText(
            creationTime: .now,
            target: MetalCombatText.Target(objectID: player.objectID, isPlayer: true),
            amount: recovered,
            kind: .hpRecovery,
            delay: .zero
        )
        renderBackend.addCombatText(combatText)
    }

    public func onPlayerSpellPointsRecovered(recovered: Int, current: Int) {
        state.overlay.gauges[player.objectID]?.sp = current

        let playerObject = objectRegistry.object(for: player.objectID) as? MetalPlayerObject
        playerObject?.sp = current

        renderBackend.updateObject(objectID: player.objectID)

        let combatText = MetalCombatText(
            creationTime: .now,
            target: MetalCombatText.Target(objectID: player.objectID, isPlayer: true),
            amount: recovered,
            kind: .spRecovery,
            delay: .zero
        )
        renderBackend.addCombatText(combatText)
    }

    public func onPlayerMoved(startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) {
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

    public func onMapObjectHealthUpdated(objectID: GameObjectID, hp: Int, maxHp: Int) {
        if let metalObject = objectRegistry.object(for: objectID) {
            metalObject.hp = hp
            metalObject.maxHp = maxHp
            renderBackend.updateObject(objectID: objectID)
        }

        state.overlay.gauges[objectID]?.hp = hp
        state.overlay.gauges[objectID]?.maxHp = maxHp
    }

    public func onMapObjectSpawned(object: MapObject, position: SIMD2<Int>, direction: Direction, headDirection: HeadDirection) {
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
            state.overlay.gauges[object.objectID] = MetalGaugeOverlay(
                id: object.objectID,
                hp: object.hp,
                maxHp: object.maxHp,
                objectType: object.type
            )
        }
    }

    public func onMapObjectMoved(object: MapObject, startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) {
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
                state.overlay.gauges[object.objectID] = MetalGaugeOverlay(
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

    public func onMapObjectStopped(objectID: GameObjectID, position: SIMD2<Int>) {
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

    public func onMapObjectVanished(objectID: GameObjectID, type: UnitClearType) {
        switch type {
        case .dead where objectID == player.objectID:
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

    public func onMapObjectResurrected(objectID: GameObjectID) {
        renderBackend.performObjectAction(
            objectID: objectID,
            action: .idle,
            completion: .indefinite
        )
        if objectID == player.objectID {
            state.isPlayerDead = false
        }
    }

    public func onMapObjectDirectionChanged(objectID: GameObjectID, direction: Direction, headDirection: HeadDirection) {
        renderBackend.turnObject(
            objectID: objectID,
            direction: SpriteDirection(direction: direction),
            headDirection: SpriteHeadDirection(headDirection: headDirection)
        )
    }

    public func onMapObjectStateChanged(objectID: GameObjectID, bodyState: StatusChangeOption1, healthState: StatusChangeOption2, effectState: StatusChangeOption) {
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
                state.overlay.gauges[objectID] = MetalGaugeOverlay(
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

    public func onMapObjectSpriteChanged(objectID: GameObjectID, look: Look, value: Int, value2: Int) {
        guard let metalObject = objectRegistry.object(for: objectID) else {
            return
        }

        switch look {
        case .base:
            metalObject.job = value
        case .hair:
            metalObject.hairStyle = value
        case .weapon:
            metalObject.weapon = value
            metalObject.shield = value2
        case .head_bottom:
            metalObject.headBottom = value
        case .head_top:
            metalObject.headTop = value
        case .head_mid:
            metalObject.headMid = value
        case .hair_color:
            metalObject.hairColor = value
        case .clothes_color:
            metalObject.clothesColor = value
        case .shield:
            metalObject.shield = value
        case .robe:
            metalObject.garment = value
        default:
            return
        }

        renderBackend.updateObject(objectID: objectID)
    }

    public func onMapObjectActionPerformed(objectAction: MapObjectAction) {
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

    public func onMapObjectSkillPerformed(objectSkill: MapObjectSkill) {
        let now = ContinuousClock.now

        if let sourceObject = objectRegistry.object(for: objectSkill.sourceObjectID) {
            let availableActionTypes = SpriteActionType.availableActionTypes(forJobID: sourceObject.job)
            let action: SpriteActionType = availableActionTypes.contains(.skill) ? .skill : .attack1
            let duration = Duration.milliseconds(objectSkill.attackDelay)
            let settledAction: SpriteActionType = availableActionTypes.contains(.readyToAttack) ? .readyToAttack : .idle

            renderBackend.performObjectAction(
                objectID: objectSkill.sourceObjectID,
                action: action,
                completion: .after(duration, settledAction: settledAction)
            )
        }

        if objectSkill.damage >= 0 {
            let count = objectSkill.count
            let damage = objectSkill.damage
            let target = MetalCombatText.Target(
                objectID: objectSkill.targetObjectID,
                isPlayer: objectRegistry.object(for: objectSkill.targetObjectID)?.type == .pc
            )

            for i in 0..<count {
                let combatText = MetalCombatText(
                    creationTime: now,
                    target: target,
                    amount: damage / count,
                    delay: .milliseconds(objectSkill.attackDelay) + .milliseconds(200 * i)
                )
                renderBackend.addCombatText(combatText)
            }
        }

        addSkillHitEffects(for: objectSkill)
        addSkillEffects(for: objectSkill)
    }

    public func onItemSpawned(item: MapItem, position: SIMD2<Int>) {
        let metalItem = MetalMapItem(item: item, gridPosition: position)
        itemRegistry.add(metalItem)

        renderBackend.addItem(metalItem)
    }

    public func onItemVanished(objectID: GameObjectID) {
        itemRegistry.remove(objectID: objectID)
        renderBackend.removeItem(objectID: objectID)
    }

    public func onGroundSkillCast(skillID: SkillID, position: SIMD2<Int>) {
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

    private func addSkillHitEffects(for objectSkill: MapObjectSkill) {
        guard objectSkill.damage > 0,
              let skillID = objectSkill.skillID,
              let targetPosition = renderBackend.gridPosition(for: objectSkill.targetObjectID) else {
            return
        }

        let now = ContinuousClock.now
        let count = max(1, objectSkill.count)
        for hitEffectID in SkillEffectTable.hitEffectIDs(for: skillID) {
            for i in 0..<count {
                addEffects(
                    forEffectID: hitEffectID,
                    creationTime: now,
                    gridPosition: targetPosition,
                    attachedObjectID: objectSkill.targetObjectID,
                    delay: .milliseconds(objectSkill.attackDelay) + .milliseconds(200 * i)
                )
            }
        }
    }

    private func addSkillEffects(for objectSkill: MapObjectSkill) {
        guard let skillID = objectSkill.skillID,
              objectRegistry.object(for: objectSkill.sourceObjectID) != nil,
              objectRegistry.object(for: objectSkill.targetObjectID) != nil,
              let targetPosition = renderBackend.gridPosition(for: objectSkill.targetObjectID),
              objectSkill.damageType != .splash, objectSkill.damageType != .splash_endure else {
            return
        }

        let now = ContinuousClock.now
        for effectID in SkillEffectTable.effectIDs(for: skillID) {
            addEffects(
                forEffectID: effectID,
                creationTime: now,
                gridPosition: targetPosition,
                attachedObjectID: objectSkill.targetObjectID,
                delay: .milliseconds(objectSkill.attackDelay)
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
