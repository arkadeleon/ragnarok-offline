//
//  MapScene+EventHandler.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import Foundation
import QuartzCore
import RagnarokConstants
import RagnarokEffects
import RagnarokModels
import RagnarokRendering
import RagnarokSprite
import simd

extension MapScene {

    // MARK: - Player

    public func onPlayerStatusChanged(property: StatusProperty, value: Int) {
        switch property {
        case .hp:
            player.hp = value
        case .maxhp:
            player.maxHp = value
        case .sp:
            player.sp = value
        case .maxsp:
            player.maxSp = value
        default:
            break
        }
    }

    public func onPlayerHealthPointsRecovered(recovered: Int, current: Int) {
        player.hp = current

        let combatText = CombatText(
            creationTime: .now,
            target: CombatText.Target(objectID: player.objectID, isPlayer: true),
            amount: recovered,
            kind: .hpRecovery,
            delay: .zero
        )
        addCombatText(combatText)
    }

    public func onPlayerSpellPointsRecovered(recovered: Int, current: Int) {
        player.sp = current

        let combatText = CombatText(
            creationTime: .now,
            target: CombatText.Target(objectID: player.objectID, isPlayer: true),
            amount: recovered,
            kind: .spRecovery,
            delay: .zero
        )
        addCombatText(combatText)
    }

    public func onPlayerMoved(startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) {
        let movement = moveObject(
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
    }

    // MARK: - Map Object

    public func onMapObjectHealthUpdated(objectID: GameObjectID, hp: Int, maxHp: Int) {
        guard let object = objects[objectID] else {
            return
        }

        object.hp = hp
        object.maxHp = maxHp

        if object.type == .monster {
            gaugeObjectIDs.insert(objectID)
        }
    }

    public func onMapObjectSpawned(object: MapObject, position: SIMD2<Int>, direction: Direction, headDirection: HeadDirection) {
        let mapObject = MapSceneMapObject(
            object: object,
            hp: object.hp,
            maxHp: object.maxHp,
            gridPosition: position,
            direction: SpriteDirection(direction: direction),
            headDirection: SpriteHeadDirection(headDirection: headDirection)
        )
        objects[object.objectID] = mapObject

        addObject(
            objectID: object.objectID,
            at: position,
            direction: SpriteDirection(direction: direction),
            headDirection: SpriteHeadDirection(headDirection: headDirection)
        )

        if object.job == 45 { // JT_WARPNPC
            addEffect(
                for: .id(.ef_warpzone2),
                creationTime: CACurrentMediaTime(),
                gridPosition: position,
                targetObjectID: object.objectID,
                ownerObjectID: object.objectID,
                delay: 0
            )
        }
    }

    public func onMapObjectMoved(object: MapObject, startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) {
        let isNew = objects[object.objectID] == nil

        if isNew {
            let mapObject = MapSceneMapObject(
                object: object,
                hp: object.hp,
                maxHp: object.maxHp,
                gridPosition: endPosition,
                direction: SpriteDirection(sourcePosition: startPosition, targetPosition: endPosition),
                headDirection: .lookForward
            )
            objects[object.objectID] = mapObject

            addObject(
                objectID: object.objectID,
                at: startPosition,
                direction: SpriteDirection(sourcePosition: startPosition, targetPosition: endPosition),
                headDirection: .lookForward
            )
        } else {
            objects[object.objectID]?.gridPosition = endPosition
        }

        _ = moveObject(
            objectID: object.objectID,
            startPosition: startPosition,
            endPosition: endPosition
        )
    }

    public func onMapObjectStopped(objectID: GameObjectID, position: SIMD2<Int>) {
        if objects[objectID] != nil {
            stopObject(objectID: objectID, at: position)
        }

        objects[objectID]?.gridPosition = position

        if objectID == player.objectID, let action = pendingArrivalAction {
            arrivalTask?.cancel()
            arrivalTask = nil
            pendingArrivalAction = nil
            action()
        }
    }

    public func onMapObjectVanished(objectID: GameObjectID, type: UnitClearType) {
        guard type == .dead, let object = objects[objectID] else {
            removeObject(objectID: objectID)
            return
        }

        object.death = MapObjectDeath(
            startTime: .now,
            fadeDuration: object.type == .pc ? nil : .seconds(5)
        )
        object.stopMovement()
        object.perform(.die, completion: .indefinite)

        gaugeObjectIDs.remove(objectID)

        if objectID == player.objectID {
            state.isPlayerDead = true
        }
    }

    public func onMapObjectResurrected(objectID: GameObjectID) {
        if let object = objects[objectID] {
            object.death = nil
            object.perform(.idle, completion: .indefinite)
        }

        if objectID == player.objectID {
            gaugeObjectIDs.insert(objectID)
            state.isPlayerDead = false
        }
    }

    public func onMapObjectDirectionChanged(objectID: GameObjectID, direction: Direction, headDirection: HeadDirection) {
        guard let object = objects[objectID] else {
            return
        }

        let direction = SpriteDirection(direction: direction)
        let headDirection = SpriteHeadDirection(headDirection: headDirection)
        object.turn(direction: direction, headDirection: headDirection)
    }

    public func onMapObjectStateChanged(objectID: GameObjectID, bodyState: StatusChangeOption1, healthState: StatusChangeOption2, effectState: StatusChangeOption) {
        if let mapObject = objects[objectID] {
            mapObject.bodyState = bodyState
            mapObject.healthState = healthState
            mapObject.effectState = effectState
        }
    }

    public func onMapObjectSpriteChanged(objectID: GameObjectID, look: Look, value: Int, value2: Int) {
        guard let mapObject = objects[objectID] else {
            return
        }

        switch look {
        case .base:
            mapObject.job = value
        case .hair:
            mapObject.hairStyle = value
        case .weapon:
            mapObject.weaponType = ItemWeaponTypeTable.weaponType(for: value) ?? .w_fist
            mapObject.shield = value2
        case .head_bottom:
            mapObject.headBottom = value
        case .head_top:
            mapObject.headTop = value
        case .head_mid:
            mapObject.headMid = value
        case .hair_color:
            mapObject.hairColor = value
        case .clothes_color:
            mapObject.clothesColor = value
        case .shield:
            mapObject.shield = value
        case .robe:
            mapObject.garment = value
        default:
            return
        }
    }

    public func onMapObjectActionPerformed(objectAction: MapObjectAction) {
        let now = ContinuousClock.now

        let sourceID = objectAction.sourceObjectID
        let sourceObject = objects[sourceID]

        let presentationActionType: SpriteActionType = switch objectAction.type {
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
                    weaponType: sourceObject.weaponType
                )
            } else {
                .attack1
            }
        default:
            .attack1
        }

        let completion: SpriteAction.Completion = switch presentationActionType {
        case .pickup:
            .once(nextActionType: .idle)
        case .sit:
            .indefinite
        case .freeze, .freeze2, .die:
            .after(.milliseconds(objectAction.sourceSpeed), nextActionType: presentationActionType)
        case .attack1, .attack2, .attack3, .skill:
            .after(.milliseconds(objectAction.sourceSpeed), nextActionType: afterAttackAction(for: sourceObject))
        case .idle, .walk, .readyToAttack, .hurt:
            .after(.milliseconds(objectAction.sourceSpeed), nextActionType: .idle)
        }

        if let sourceObject {
            if presentationActionType.isAttack {
                sourceObject.attackDelay = .milliseconds(objectAction.sourceSpeed)
                if let targetObject = objects[objectAction.targetObjectID] {
                    sourceObject.setDirection(SpriteDirection(sourcePosition: sourceObject.gridPosition, targetPosition: targetObject.gridPosition))
                }
                if SpriteJob(rawValue: sourceObject.job).isPlayer {
                    audioPlayer.playSound(named: WeaponSoundTable.attackSoundNames(for: sourceObject.weaponType).randomElement())
                }
            }

            sourceObject.perform(presentationActionType, completion: completion)
        }

        addCombatTextsAndPlayHitSound(for: objectAction, now: now)

        addHitEffect(for: objectAction)
        addArrowProjectileEffect(for: objectAction)
    }

    public func onMapObjectSkillCast(skillID: SkillID, sourceObjectID: GameObjectID) {
        guard let sourceObject = objects[sourceObjectID] else {
            return
        }

        let currentTime = CACurrentMediaTime()

        for effectReference in SkillEffectTable.beginCastEffects(for: skillID) {
            addEffect(
                for: effectReference,
                creationTime: currentTime,
                gridPosition: sourceObject.gridPosition,
                targetObjectID: sourceObjectID,
                ownerObjectID: sourceObjectID,
                delay: 0
            )
        }
    }

    public func onMapObjectSkillPerformed(objectSkill: MapObjectSkill) {
        let now = ContinuousClock.now

        if let sourceObject = objects[objectSkill.sourceObjectID] {
            if let targetObject = objects[objectSkill.targetObjectID] {
                sourceObject.setDirection(SpriteDirection(sourcePosition: sourceObject.gridPosition, targetPosition: targetObject.gridPosition))
            }

            let availableActionTypes = SpriteActionType.availableActionTypes(forJobID: sourceObject.job)
            let action: SpriteActionType = availableActionTypes.contains(.skill) ? .skill : .attack1
            let duration = Duration.milliseconds(objectSkill.attackDelay)
            let nextActionType: SpriteActionType = availableActionTypes.contains(.readyToAttack) ? .readyToAttack : .idle

            sourceObject.attackDelay = duration
            sourceObject.perform(action, completion: .after(duration, nextActionType: nextActionType))
        }

        if objectSkill.isHealingSkill, let targetObject = objects[objectSkill.targetObjectID] {
            let combatText = CombatText(
                creationTime: now,
                target: CombatText.Target(
                    objectID: objectSkill.targetObjectID,
                    isPlayer: targetObject.type == .pc
                ),
                amount: objectSkill.level,
                kind: .hpRecovery,
                delay: .zero
            )
            addCombatText(combatText)

            audioPlayer.playSound(named: "_heal_effect.wav")
        }

        if objectSkill.damage >= 0 {
            let count = objectSkill.count
            let damage = objectSkill.damage
            let target = CombatText.Target(
                objectID: objectSkill.targetObjectID,
                isPlayer: objects[objectSkill.targetObjectID]?.type == .pc
            )

            let showsComboText = count > 1 && damage > 0 && isMonster(objectID: objectSkill.targetObjectID)

            for i in 0..<count {
                let delay: Duration = .milliseconds(objectSkill.attackDelay) + .milliseconds(200 * i)

                let combatText = CombatText(
                    creationTime: now,
                    target: target,
                    amount: damage / count,
                    delay: delay
                )
                addCombatText(combatText)

                if showsComboText {
                    let comboText = CombatText(
                        creationTime: now,
                        target: target,
                        amount: damage * (i + 1) / count,
                        kind: i + 1 == count ? .finalCombo : .combo,
                        delay: delay
                    )
                    addCombatText(comboText)
                }
            }
        }

        addSkillBeforeHitEffects(for: objectSkill)
        addSkillHitEffects(for: objectSkill)
        addSkillEffects(for: objectSkill)
        addSkillSuccessEffects(for: objectSkill)
    }

    // MARK: - Dropped Item

    public func onItemSpawned(item: DroppedItem, position: SIMD2<Int>) {
        let droppedItem = MapSceneDroppedItem(item: item, gridPosition: position)
        items[item.objectID] = droppedItem
    }

    public func onItemVanished(objectID: GameObjectID) {
        items.removeValue(forKey: objectID)
    }

    // MARK: - Effect

    public func onSpecialEffectSpawned(effect: NotifyEffect, objectID: GameObjectID) {
        guard let object = objects[objectID] else {
            return
        }

        let effectID: EffectID? = switch effect {
        case .base_level_up:
            .ef_angel
        case .job_level_up:
            .ef_joblvup
        default:
            nil
        }

        if let effectID {
            addEffect(
                for: .id(effectID),
                creationTime: CACurrentMediaTime(),
                gridPosition: object.gridPosition,
                targetObjectID: objectID,
                ownerObjectID: objectID,
                delay: 0
            )
        }
    }

    // MARK: - Other

    public func onGroundSkillCast(skillID: SkillID, sourceObjectID: GameObjectID, position: SIMD2<Int>) {
        guard mapGrid.contains(position) else {
            return
        }

        let currentTime = CACurrentMediaTime()

        for effectReference in SkillEffectTable.effects(for: skillID) {
            addEffect(
                for: effectReference,
                creationTime: currentTime,
                gridPosition: position,
                sourceWorldPosition: worldPosition(forObjectID: sourceObjectID),
                targetObjectID: nil,
                ownerObjectID: nil,
                delay: 0
            )
        }
    }
}

// MARK: - Map Object

extension MapScene {
    func addObject(objectID: GameObjectID, at gridPosition: SIMD2<Int>, direction: SpriteDirection, headDirection: SpriteHeadDirection) {
        guard let object = objects[objectID] else {
            return
        }
        object.gridPosition = gridPosition
        object.perform(.idle, completion: .indefinite)
        object.turn(direction: direction, headDirection: headDirection)
    }

    func removeObject(objectID: GameObjectID) {
        objects.removeValue(forKey: objectID)
        gaugeObjectIDs.remove(objectID)

        let ownedEffectObjectIDs = effects.compactMap { effectID, effect in
            effect.ownerObjectID == objectID ? effectID : nil
        }
        for effectObjectID in ownedEffectObjectIDs {
            removeEffect(objectID: effectObjectID)
        }
    }

    func moveObject(objectID: GameObjectID, startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) -> MapObjectMovement? {
        guard let object = objects[objectID] else {
            return nil
        }

        let now = ContinuousClock.now
        let movement = object.replanMovement(
            startPosition: startPosition,
            endPosition: endPosition,
            speed: object.speed,
            pathFinder: pathFinder,
            at: now
        )

        object.gridPosition = movement.currentPosition
        let remainingDuration = movement.remainingDuration(at: now)
        object.perform(
            .walk,
            completion: .after(remainingDuration, nextActionType: .idle),
            at: now
        )
        object.setDirection(movement.finalDirection)

        return movement
    }

    func stopObject(objectID: GameObjectID, at position: SIMD2<Int>) {
        if let object = objects[objectID] {
            object.gridPosition = position
            object.stopMovement()
            object.perform(.idle, completion: .indefinite)
        }
    }

    private func afterAttackAction(for object: MapSceneMapObject?) -> SpriteActionType {
        guard let object else {
            return .idle
        }

        let availableActionTypes = SpriteActionType.availableActionTypes(forJobID: object.job)
        return availableActionTypes.contains(.readyToAttack) ? .readyToAttack : .idle
    }

    private func isMonster(objectID: GameObjectID) -> Bool {
        switch objects[objectID]?.type {
        case .monster, .abr, .bionic:
            true
        default:
            false
        }
    }
}

// MARK: - Combat Text

extension MapScene {
    private func addCombatTextsAndPlayHitSound(for objectAction: MapObjectAction, now: ContinuousClock.Instant) {
        let target = CombatText.Target(
            objectID: objectAction.targetObjectID,
            isPlayer: objects[objectAction.targetObjectID]?.type == .pc
        )
        let hitSoundName = hitSoundName(for: objectAction)

        switch objectAction.type {
        case .normal, .endure, .critical:
            let combatText = CombatText(
                creationTime: now,
                target: target,
                amount: objectAction.damage,
                delay: .milliseconds(objectAction.sourceSpeed)
            )
            addCombatText(combatText)
            audioPlayer.playSound(named: hitSoundName, after: combatText.delay)

            if objectAction.damage2 > 0 {
                let combatText2 = CombatText(
                    creationTime: now,
                    target: target,
                    amount: objectAction.damage2,
                    delay: .milliseconds(objectAction.sourceSpeed) + .milliseconds(200 * 1.75)
                )
                addCombatText(combatText2)
                audioPlayer.playSound(named: hitSoundName, after: combatText2.delay)
            }
        case .multi_hit, .multi_hit_endure, .multi_hit_critical:
            let count = objectAction.damage > 1 ? 2 : 1
            if count == 2 {
                let combatText = CombatText(
                    creationTime: now,
                    target: target,
                    amount: objectAction.damage / count,
                    delay: .milliseconds(objectAction.sourceSpeed)
                )
                addCombatText(combatText)
                audioPlayer.playSound(named: hitSoundName, after: combatText.delay)
            }
            if objectAction.damage2 > 0 {
                let combatText = CombatText(
                    creationTime: now,
                    target: target,
                    amount: objectAction.damage / count,
                    delay: .milliseconds(objectAction.sourceSpeed) + .milliseconds(200 / 2)
                )
                addCombatText(combatText)
                audioPlayer.playSound(named: hitSoundName, after: combatText.delay)

                let combatText2 = CombatText(
                    creationTime: now,
                    target: target,
                    amount: objectAction.damage2,
                    delay: .milliseconds(objectAction.sourceSpeed) + .milliseconds(200 * 1.75)
                )
                addCombatText(combatText2)
                audioPlayer.playSound(named: hitSoundName, after: combatText2.delay)
            } else {
                let combatText = CombatText(
                    creationTime: now,
                    target: target,
                    amount: objectAction.damage / count,
                    delay: .milliseconds(objectAction.sourceSpeed) + .milliseconds(200)
                )
                addCombatText(combatText)
                audioPlayer.playSound(named: hitSoundName, after: combatText.delay)
            }

            // Monsters taking more than one hit show a combo text.
            if objectAction.damage > 0, isMonster(objectID: objectAction.targetObjectID) {
                if objectAction.damage > 1 {
                    let comboText = CombatText(
                        creationTime: now,
                        target: target,
                        amount: objectAction.damage / 2,
                        kind: .combo,
                        delay: .milliseconds(objectAction.sourceSpeed)
                    )
                    addCombatText(comboText)
                }

                if objectAction.damage2 > 0 {
                    let comboText = CombatText(
                        creationTime: now,
                        target: target,
                        amount: objectAction.damage,
                        kind: .combo,
                        delay: .milliseconds(objectAction.sourceSpeed) + .milliseconds(200 / 2)
                    )
                    addCombatText(comboText)

                    let finalComboText = CombatText(
                        creationTime: now,
                        target: target,
                        amount: objectAction.damage + objectAction.damage2,
                        kind: .finalCombo,
                        delay: .milliseconds(objectAction.sourceSpeed) + .milliseconds(200 * 1.75)
                    )
                    addCombatText(finalComboText)
                } else {
                    let finalComboText = CombatText(
                        creationTime: now,
                        target: target,
                        amount: objectAction.damage,
                        kind: .finalCombo,
                        delay: .milliseconds(objectAction.sourceSpeed) + .milliseconds(200)
                    )
                    addCombatText(finalComboText)
                }
            }
        default:
            break
        }
    }

    private func addCombatText(_ combatText: CombatText) {
        guard combatTexts[combatText.id] == nil else {
            return
        }

        guard let startWorldPosition = worldPosition(forObjectID: combatText.target.objectID) else {
            return
        }

        guard renderResources.addCombatText(
            combatText,
            startWorldPosition: startWorldPosition
        ) else {
            return
        }

        combatTexts[combatText.id] = combatText
    }
}

// MARK: - Effect

extension MapScene {
    private func addHitEffect(for objectAction: MapObjectAction) {
        guard objectAction.damage > 0,
              isMonster(objectID: objectAction.targetObjectID),
              let targetObject = objects[objectAction.targetObjectID] else {
            return
        }

        addEffect(
            for: .id(.ef_hit1),
            creationTime: CACurrentMediaTime(),
            gridPosition: targetObject.gridPosition,
            targetObjectID: targetObject.objectID,
            ownerObjectID: nil,
            delay: .milliseconds(objectAction.sourceSpeed)
        )
    }

    private func addArrowProjectileEffect(for objectAction: MapObjectAction) {
        let isAttackAction = switch objectAction.type {
        case .normal, .endure, .critical, .multi_hit, .multi_hit_endure, .multi_hit_critical, .lucy_dodge:
            true
        default:
            false
        }

        guard isAttackAction,
              let sourceObject = objects[objectAction.sourceObjectID],
              let targetObject = objects[objectAction.targetObjectID],
              SpriteJob(rawValue: sourceObject.job).isPlayer,
              sourceObject.weaponType == .w_bow else {
            return
        }

        addEffect(
            for: .name("ef_arrow_projectile"),
            creationTime: CACurrentMediaTime(),
            gridPosition: targetObject.gridPosition,
            sourceWorldPosition: worldPosition(for: sourceObject),
            targetObjectID: targetObject.objectID,
            ownerObjectID: nil,
            delay: .milliseconds(objectAction.sourceSpeed)
        )
    }

    private func addSkillBeforeHitEffects(for objectSkill: MapObjectSkill) {
        guard objectSkill.damage > 0,
              let skillID = objectSkill.skillID,
              let targetPosition = objects[objectSkill.targetObjectID]?.gridPosition else {
            return
        }

        let currentTime = CACurrentMediaTime()
        let count = max(1, objectSkill.count)

        for effectReference in SkillEffectTable.beforeHitEffects(for: skillID) {
            for i in 0..<count {
                addEffect(
                    for: effectReference,
                    creationTime: currentTime,
                    gridPosition: targetPosition,
                    sourceWorldPosition: worldPosition(forObjectID: objectSkill.sourceObjectID),
                    targetObjectID: objectSkill.targetObjectID,
                    ownerObjectID: nil,
                    delay: .milliseconds(200 * i)
                )
            }
        }
    }

    private func addSkillHitEffects(for objectSkill: MapObjectSkill) {
        guard objectSkill.damage > 0,
              let skillID = objectSkill.skillID,
              let targetPosition = objects[objectSkill.targetObjectID]?.gridPosition else {
            return
        }

        let currentTime = CACurrentMediaTime()
        let count = max(1, objectSkill.count)

        for effectReference in SkillEffectTable.hitEffects(for: skillID) {
            for i in 0..<count {
                addEffect(
                    for: effectReference,
                    creationTime: currentTime,
                    gridPosition: targetPosition,
                    sourceWorldPosition: worldPosition(forObjectID: objectSkill.sourceObjectID),
                    targetObjectID: objectSkill.targetObjectID,
                    ownerObjectID: nil,
                    delay: .milliseconds(objectSkill.attackDelay) + .milliseconds(200 * i)
                )
            }
        }
    }

    private func addSkillEffects(for objectSkill: MapObjectSkill) {
        guard let skillID = objectSkill.skillID,
              objects[objectSkill.sourceObjectID] != nil,
              objects[objectSkill.targetObjectID] != nil,
              let targetPosition = objects[objectSkill.targetObjectID]?.gridPosition,
              objectSkill.damageType != .splash, objectSkill.damageType != .splash_endure else {
            return
        }

        let currentTime = CACurrentMediaTime()

        for effectReference in SkillEffectTable.effects(for: skillID) {
            addEffect(
                for: effectReference,
                creationTime: currentTime,
                gridPosition: targetPosition,
                sourceWorldPosition: worldPosition(forObjectID: objectSkill.sourceObjectID),
                targetObjectID: objectSkill.targetObjectID,
                ownerObjectID: nil,
                delay: .milliseconds(objectSkill.attackDelay)
            )
        }
    }

    private func addSkillSuccessEffects(for objectSkill: MapObjectSkill) {
        guard objectSkill.isSuccess,
              let skillID = objectSkill.skillID,
              let targetPosition = objects[objectSkill.targetObjectID]?.gridPosition else {
            return
        }

        let currentTime = CACurrentMediaTime()

        for effectReference in SkillEffectTable.successEffects(for: skillID) {
            addEffect(
                for: effectReference,
                creationTime: currentTime,
                gridPosition: targetPosition,
                sourceWorldPosition: worldPosition(forObjectID: objectSkill.sourceObjectID),
                targetObjectID: objectSkill.targetObjectID,
                ownerObjectID: nil,
                delay: 0
            )
        }
    }

    private func addEffect(
        for effectReference: EffectReference,
        creationTime: TimeInterval,
        gridPosition: SIMD2<Int>,
        sourceWorldPosition: SIMD3<Float>? = nil,
        targetObjectID: GameObjectID?,
        ownerObjectID: GameObjectID?,
        delay: TimeInterval
    ) {
        let effect = MapSceneEffect(
            reference: effectReference,
            creationTime: creationTime,
            gridPosition: gridPosition,
            sourceWorldPosition: sourceWorldPosition,
            targetObjectID: targetObjectID,
            ownerObjectID: ownerObjectID,
            delay: delay
        )
        addEffect(effect)
    }

    private func addEffect(_ effect: MapSceneEffect) {
        let effectID = effect.id
        effects[effectID] = effect

        renderResources.addEffect(
            effect,
            worldPosition: mapGrid.worldPosition(for: effect.gridPosition)
        ) { [audioPlayer] soundName, delay in
            audioPlayer.playSound(named: soundName, after: .seconds(delay))
        }
    }

    func removeEffect(objectID: UUID) {
        effects.removeValue(forKey: objectID)
        renderResources.removeEffect(id: objectID)
    }
}

// MARK: - Sound

extension MapScene {
    private func hitSoundName(for objectAction: MapObjectAction) -> String? {
        guard objectAction.damage > 0,
              let targetObject = objects[objectAction.targetObjectID] else {
            return nil
        }

        let sourceObject = objects[objectAction.sourceObjectID]
        let targetJob = SpriteJob(rawValue: targetObject.job)

        if targetJob.isPlayer {
            return JobHitSoundTable.hitSoundNames(forJob: targetObject.job).randomElement()
        } else if let sourceObject, SpriteJob(rawValue: sourceObject.job).isPlayer {
            let weaponHitSoundName = WeaponHitSoundTable.hitSoundNames(for: sourceObject.weaponType).randomElement()
            return weaponHitSoundName ?? JobHitSoundTable.hitSoundNames(forJob: targetObject.job).randomElement()
        } else {
            return JobHitSoundTable.hitSoundNames(forJob: targetObject.job).randomElement()
        }
    }
}
