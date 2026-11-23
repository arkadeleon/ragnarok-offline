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
        case .speed:
            world.player.speed = value
        case .hp:
            world.player.hp = value
        case .maxhp:
            world.player.maxHp = value
        case .sp:
            world.player.sp = value
        case .maxsp:
            world.player.maxSp = value
        default:
            break
        }
    }

    public func onPlayerHealthPointsRecovered(recovered: Int, current: Int) {
        world.player.hp = current

        let combatText = CombatText(
            creationTime: CACurrentMediaTime(),
            target: CombatText.Target(
                objectID: world.player.objectID,
                initialWorldPosition: world.player.worldPosition,
                isPlayer: true
            ),
            amount: recovered,
            kind: .hpRecovery,
            delay: 0
        )
        world.combatTexts.append(combatText)
    }

    public func onPlayerSpellPointsRecovered(recovered: Int, current: Int) {
        world.player.sp = current

        let combatText = CombatText(
            creationTime: CACurrentMediaTime(),
            target: CombatText.Target(
                objectID: world.player.objectID,
                initialWorldPosition: world.player.worldPosition,
                isPlayer: true
            ),
            amount: recovered,
            kind: .spRecovery,
            delay: 0
        )
        world.combatTexts.append(combatText)
    }

    public func onPlayerMoved(startTime: TimeInterval, startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) {
        moveObject(
            objectID: world.player.objectID,
            startTime: startTime,
            startPosition: startPosition,
            endPosition: endPosition
        )

        applyThumbstickStopPosition(toMovementEndingAt: endPosition)
        scheduleArrivalAction()
    }

    public func onPlayerTooFarToAttack(targetID: GameObjectID) {
        attackMonster(targetID: targetID)
    }

    // MARK: - Map Object

    public func onMapObjectHealthUpdated(objectID: GameObjectID, hp: Int, maxHp: Int) {
        guard let object = world.objects[objectID] else {
            return
        }

        object.hp = hp
        object.maxHp = maxHp

        if object.type == .monster {
            object.showsHPSPBar = true
        }
    }

    public func onMapObjectSpawned(object: MapObject, position: SIMD2<Int>, direction: Direction, headDirection: HeadDirection) {
        let mapObject = MapSceneMapObject(
            object: object,
            hp: object.hp,
            maxHp: object.maxHp,
            gridPosition: position,
            worldPosition: world.mapGrid.worldPosition(for: position),
            direction: SpriteDirection(direction: direction),
            headDirection: SpriteHeadDirection(headDirection: headDirection)
        )
        registerObject(mapObject)

        addObject(
            objectID: object.objectID,
            at: position,
            direction: SpriteDirection(direction: direction),
            headDirection: SpriteHeadDirection(headDirection: headDirection)
        )

        switch object.deadSitState {
        case .standing:
            break
        case .dead:
            mapObject.death = MapObjectDeath(
                startTime: CACurrentMediaTime(),
                fadeDuration: object.type == .pc ? nil : 5
            )
            mapObject.perform(.die, completion: .indefinite)
        case .sitting:
            mapObject.perform(.sit, completion: .indefinite)
        }

        if object.job == 45 { // JT_WARPNPC
            let effect = MapSceneEffect(
                reference: .id(.ef_warpzone2),
                creationTime: CACurrentMediaTime(),
                gridPosition: position,
                worldPosition: mapObject.worldPosition,
                targetObjectID: object.objectID,
                ownerObjectID: object.objectID
            )
            addEffect(effect)
        }
    }

    public func onMapObjectMoved(object: MapObject, startTime: TimeInterval, startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) {
        let isNew = world.objects[object.objectID] == nil

        if isNew {
            let mapObject = MapSceneMapObject(
                object: object,
                hp: object.hp,
                maxHp: object.maxHp,
                gridPosition: endPosition,
                worldPosition: world.mapGrid.worldPosition(for: endPosition),
                direction: SpriteDirection(sourcePosition: startPosition, targetPosition: endPosition),
                headDirection: .lookForward
            )
            registerObject(mapObject)

            addObject(
                objectID: object.objectID,
                at: startPosition,
                direction: SpriteDirection(sourcePosition: startPosition, targetPosition: endPosition),
                headDirection: .lookForward
            )
        } else {
            world.objects[object.objectID]?.speed = object.speed
        }

        moveObject(
            objectID: object.objectID,
            startTime: startTime,
            startPosition: startPosition,
            endPosition: endPosition
        )
    }

    public func onMapObjectStopped(objectID: GameObjectID, position: SIMD2<Int>) {
        if world.objects[objectID] != nil {
            stopObject(objectID: objectID, at: position)
        }

        if objectID == world.player.objectID {
            performArrivalAction()
        }
    }

    public func onMapObjectVanished(objectID: GameObjectID, type: UnitClearType) {
        guard type == .dead, let object = world.objects[objectID] else {
            if type == .respawn || type == .teleport,
               let object = world.objects[objectID], object.effectState != .invisible {
                let effect = MapSceneEffect(
                    reference: .id(.ef_teleportation2),
                    creationTime: CACurrentMediaTime(),
                    gridPosition: object.gridPosition,
                    worldPosition: object.worldPosition,
                    targetObjectID: nil,
                    ownerObjectID: nil
                )
                addEffect(effect)
            }

            removeObject(objectID: objectID)
            return
        }

        object.showsHPSPBar = false
        object.death = MapObjectDeath(
            startTime: CACurrentMediaTime(),
            fadeDuration: object.type == .pc ? nil : 5
        )
        object.movement = nil
        object.perform(.die, completion: .indefinite)
        cancelCast(for: object)

        if selectedTargetID == objectID {
            selectTarget(nil)
        }

        if objectID == world.player.objectID {
            state.isPlayerDead = true
        }
    }

    public func onMapObjectResurrected(objectID: GameObjectID) {
        if let object = world.objects[objectID] {
            object.death = nil
            object.perform(.idle, completion: .indefinite)
            if objectID == world.player.objectID {
                object.showsHPSPBar = true
            }
        }

        if objectID == world.player.objectID {
            state.isPlayerDead = false
        }
    }

    public func onMapObjectDirectionChanged(objectID: GameObjectID, direction: Direction, headDirection: HeadDirection) {
        guard let object = world.objects[objectID] else {
            return
        }

        let direction = SpriteDirection(direction: direction)
        let headDirection = SpriteHeadDirection(headDirection: headDirection)
        object.turn(direction: direction, headDirection: headDirection)
    }

    public func onMapObjectStateChanged(objectID: GameObjectID, bodyState: StatusChangeOption1, healthState: StatusChangeOption2, effectState: StatusChangeOption) {
        if let mapObject = world.objects[objectID] {
            mapObject.bodyState = bodyState
            mapObject.healthState = healthState
            mapObject.effectState = effectState
        }
    }

    public func onMapObjectSpriteChanged(objectID: GameObjectID, look: Look, value: Int, value2: Int) {
        guard let mapObject = world.objects[objectID] else {
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

        notifyObjectSpriteChanged(mapObject)
    }

    public func onMapObjectActionPerformed(objectAction: MapObjectAction) {
        let currentTime = CACurrentMediaTime()

        let sourceID = objectAction.sourceObjectID
        let sourceObject = world.objects[sourceID]

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
            .after(TimeInterval(objectAction.sourceSpeed) / 1000, nextActionType: presentationActionType)
        case .attack1, .attack2, .attack3, .skill:
            .after(TimeInterval(objectAction.sourceSpeed) / 1000, nextActionType: sourceObject.map { SpriteActionType.afterAttackActionType(forJobID: $0.job) } ?? .idle)
        case .idle, .walk, .readyToAttack, .hurt:
            .after(TimeInterval(objectAction.sourceSpeed) / 1000, nextActionType: .idle)
        }

        if let sourceObject {
            if presentationActionType.isAttack {
                sourceObject.attackDelay = TimeInterval(objectAction.sourceSpeed) / 1000
                if let targetObject = world.objects[objectAction.targetObjectID] {
                    sourceObject.setDirection(SpriteDirection(sourcePosition: sourceObject.gridPosition, targetPosition: targetObject.gridPosition))
                }
            }

            sourceObject.perform(presentationActionType, completion: completion)
        }

        let hits = MapObjectHit.hits(for: objectAction)

        addCombatTexts(for: hits, targetObjectID: objectAction.targetObjectID, hitSoundName: hitSoundName(for: objectAction), currentTime: currentTime)

        addHitEffect(for: objectAction)
        addArrowProjectileEffect(for: objectAction)
    }

    public func onMapObjectSkillCast(skillID: SkillID, sourceObjectID: GameObjectID, element: Element, castTime: TimeInterval) {
        guard let sourceObject = world.objects[sourceObjectID] else {
            return
        }

        let currentTime = CACurrentMediaTime()

        cancelCast(for: sourceObject)

        if castTime > 0 {
            let effectID: EffectID = switch element {
            case .water: .ef_beginspell2
            case .earth: .ef_beginspell5
            case .fire: .ef_beginspell3
            case .wind: .ef_beginspell4
            case .poison: .ef_beginspell7
            case .holy, .ghost: .ef_beginspell6
            case .dark, .undead: .ef_darkcasting
            default: .ef_beginspell
            }

            let spellEffect = MapSceneEffect(
                reference: .id(effectID),
                creationTime: currentTime,
                gridPosition: sourceObject.gridPosition,
                worldPosition: sourceObject.worldPosition,
                targetObjectID: sourceObjectID,
                ownerObjectID: sourceObjectID,
                attachmentKey: .cast,
                duration: castTime
            )
            addEffect(spellEffect)

            sourceObject.cast = MapObjectCast(
                startTime: currentTime,
                duration: castTime
            )
        }

        for effectReference in SkillEffectTable.beginCastEffects(for: skillID) {
            let effect = MapSceneEffect(
                reference: effectReference,
                creationTime: currentTime,
                gridPosition: sourceObject.gridPosition,
                worldPosition: sourceObject.worldPosition,
                targetObjectID: sourceObjectID,
                ownerObjectID: sourceObjectID,
                attachmentKey: .cast
            )
            addEffect(effect)
        }
    }

    public func onMapObjectSkillCastCancelled(sourceObjectID: GameObjectID) {
        if let sourceObject = world.objects[sourceObjectID] {
            cancelCast(for: sourceObject)
        }
    }

    public func onMapObjectSkillPerformed(objectSkill: MapObjectSkill) {
        let currentTime = CACurrentMediaTime()

        if let sourceObject = world.objects[objectSkill.sourceObjectID] {
            if let targetObject = world.objects[objectSkill.targetObjectID] {
                sourceObject.setDirection(SpriteDirection(sourcePosition: sourceObject.gridPosition, targetPosition: targetObject.gridPosition))
            }

            let availableActionTypes = SpriteActionType.availableActionTypes(forJobID: sourceObject.job)
            let action: SpriteActionType = availableActionTypes.contains(.skill) ? .skill : .attack1
            let duration = TimeInterval(objectSkill.attackDelay) / 1000
            let nextActionType = SpriteActionType.afterAttackActionType(forJobID: sourceObject.job)

            sourceObject.attackDelay = duration
            sourceObject.perform(action, completion: .after(duration, nextActionType: nextActionType))
        }

        if objectSkill.isHealingSkill, let targetObject = world.objects[objectSkill.targetObjectID] {
            let combatText = CombatText(
                creationTime: currentTime,
                target: CombatText.Target(
                    objectID: objectSkill.targetObjectID,
                    initialWorldPosition: targetObject.worldPosition,
                    isPlayer: targetObject.type == .pc
                ),
                amount: objectSkill.level,
                kind: .hpRecovery,
                delay: 0
            )
            world.combatTexts.append(combatText)

            audioPlayer.playSoundEffect(named: "_heal_effect.wav")
        }

        let hits = MapObjectHit.hits(for: objectSkill)

        addCombatTexts(for: hits, targetObjectID: objectSkill.targetObjectID, currentTime: currentTime)

        addSkillBeforeHitEffects(for: objectSkill, hits: hits)
        addSkillHitEffects(for: objectSkill, hits: hits)
        addSkillEffects(for: objectSkill)
        addSkillSuccessEffects(for: objectSkill)
    }

    // MARK: - Dropped Item

    public func onItemSpawned(item: DroppedItem, position: SIMD2<Int>) {
        let droppedItem = MapSceneDroppedItem(
            item: item,
            gridPosition: position,
            worldPosition: world.mapGrid.worldPosition(for: position)
        )
        addItem(droppedItem)
    }

    public func onItemVanished(objectID: GameObjectID) {
        removeItem(objectID: objectID)
    }

    // MARK: - Effect

    public func onSpecialEffectSpawned(effect: NotifyEffect, objectID: GameObjectID) {
        guard let object = world.objects[objectID] else {
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
            let effect = MapSceneEffect(
                reference: .id(effectID),
                creationTime: CACurrentMediaTime(),
                gridPosition: object.gridPosition,
                worldPosition: object.worldPosition,
                targetObjectID: objectID,
                ownerObjectID: objectID
            )
            addEffect(effect)
        }
    }

    public func onEffectSpawned(effectID: EffectID, objectID: GameObjectID) {
        guard let object = world.objects[objectID] else {
            return
        }

        let effect = MapSceneEffect(
            reference: .id(effectID),
            creationTime: CACurrentMediaTime(),
            gridPosition: object.gridPosition,
            worldPosition: object.worldPosition,
            targetObjectID: objectID,
            ownerObjectID: objectID
        )
        addEffect(effect)
    }

    // MARK: - Other

    public func onGroundSkillCast(skillID: SkillID, sourceObjectID: GameObjectID, position: SIMD2<Int>) {
        guard world.mapGrid.contains(position) else {
            return
        }

        let currentTime = CACurrentMediaTime()
        let worldPosition = world.mapGrid.worldPosition(for: position)

        for effectReference in SkillEffectTable.effects(for: skillID) {
            let effect = MapSceneEffect(
                reference: effectReference,
                creationTime: currentTime,
                gridPosition: position,
                worldPosition: worldPosition,
                sourceWorldPosition: world.objects[sourceObjectID]?.worldPosition,
                targetObjectID: nil,
                sourceObjectID: sourceObjectID,
                ownerObjectID: nil
            )
            addEffect(effect)
        }
    }
}

// MARK: - Combat Text

extension MapScene {
    private func addCombatTexts(for hits: [MapObjectHit], targetObjectID: GameObjectID, hitSoundName: String? = nil, currentTime: TimeInterval) {
        guard !hits.isEmpty, let initialWorldPosition = world.objects[targetObjectID]?.worldPosition else {
            return
        }

        let target = CombatText.Target(
            objectID: targetObjectID,
            initialWorldPosition: initialWorldPosition,
            isPlayer: world.objects[targetObjectID]?.type == .pc
        )
        let hitSoundSource = GameAudio.Source(position: initialWorldPosition, range: .infinity)
        let showsCombo = isMonster(objectID: targetObjectID)

        for hit in hits {
            let combatText = CombatText(
                creationTime: currentTime,
                target: target,
                amount: hit.damage,
                delay: hit.delay
            )
            world.combatTexts.append(combatText)

            // Monsters taking more than one hit show a combo text.
            if showsCombo, let combo = hit.combo {
                let comboText = CombatText(
                    creationTime: currentTime,
                    target: target,
                    amount: combo.damage,
                    kind: combo.isFinal ? .finalCombo : .combo,
                    delay: hit.delay
                )
                world.combatTexts.append(comboText)
            }

            if let hitSoundName {
                audioPlayer.playSoundEffect(named: hitSoundName, from: hitSoundSource, afterDelay: hit.delay)
            }
        }
    }
}

// MARK: - Effect

extension MapScene {
    private func addHitEffect(for objectAction: MapObjectAction) {
        guard objectAction.damage > 0,
              isMonster(objectID: objectAction.targetObjectID),
              let targetObject = world.objects[objectAction.targetObjectID] else {
            return
        }

        let effect = MapSceneEffect(
            reference: .id(.ef_hit1),
            creationTime: CACurrentMediaTime(),
            gridPosition: targetObject.gridPosition,
            worldPosition: targetObject.worldPosition,
            targetObjectID: targetObject.objectID,
            ownerObjectID: nil,
            delay: TimeInterval(objectAction.sourceSpeed) / 1000
        )
        addEffect(effect)
    }

    private func addArrowProjectileEffect(for objectAction: MapObjectAction) {
        let isAttackAction = switch objectAction.type {
        case .normal, .endure, .critical, .multi_hit, .multi_hit_endure, .multi_hit_critical, .lucy_dodge:
            true
        default:
            false
        }

        guard isAttackAction,
              let sourceObject = world.objects[objectAction.sourceObjectID],
              let targetObject = world.objects[objectAction.targetObjectID],
              SpriteJob(rawValue: sourceObject.job).isPlayer,
              sourceObject.weaponType == .w_bow else {
            return
        }

        let effect = MapSceneEffect(
            reference: .name("ef_arrow_projectile"),
            creationTime: CACurrentMediaTime(),
            gridPosition: targetObject.gridPosition,
            worldPosition: targetObject.worldPosition,
            sourceWorldPosition: sourceObject.worldPosition,
            targetObjectID: targetObject.objectID,
            sourceObjectID: objectAction.sourceObjectID,
            ownerObjectID: nil,
            delay: TimeInterval(objectAction.sourceSpeed) / 1000
        )
        addEffect(effect)
    }

    private func addSkillBeforeHitEffects(for objectSkill: MapObjectSkill, hits: [MapObjectHit]) {
        guard objectSkill.damage > 0,
              let skillID = objectSkill.skillID,
              let targetObject = world.objects[objectSkill.targetObjectID] else {
            return
        }

        let currentTime = CACurrentMediaTime()

        for effectReference in SkillEffectTable.beforeHitEffects(for: skillID) {
            for i in hits.indices {
                let effect = MapSceneEffect(
                    reference: effectReference,
                    creationTime: currentTime,
                    gridPosition: targetObject.gridPosition,
                    worldPosition: targetObject.worldPosition,
                    sourceWorldPosition: world.objects[objectSkill.sourceObjectID]?.worldPosition,
                    targetObjectID: objectSkill.targetObjectID,
                    sourceObjectID: objectSkill.sourceObjectID,
                    ownerObjectID: nil,
                    level: objectSkill.level,
                    delay: MapObjectHit.multiHitInterval * TimeInterval(i)
                )
                addEffect(effect)
            }
        }
    }

    private func addSkillHitEffects(for objectSkill: MapObjectSkill, hits: [MapObjectHit]) {
        guard objectSkill.damage > 0,
              let skillID = objectSkill.skillID,
              let targetObject = world.objects[objectSkill.targetObjectID] else {
            return
        }

        let currentTime = CACurrentMediaTime()

        for effectReference in SkillEffectTable.hitEffects(for: skillID) {
            for hit in hits {
                let effect = MapSceneEffect(
                    reference: effectReference,
                    creationTime: currentTime,
                    gridPosition: targetObject.gridPosition,
                    worldPosition: targetObject.worldPosition,
                    sourceWorldPosition: world.objects[objectSkill.sourceObjectID]?.worldPosition,
                    targetObjectID: objectSkill.targetObjectID,
                    sourceObjectID: objectSkill.sourceObjectID,
                    ownerObjectID: nil,
                    level: objectSkill.level,
                    delay: hit.delay
                )
                addEffect(effect)
            }
        }
    }

    private func addSkillEffects(for objectSkill: MapObjectSkill) {
        guard let skillID = objectSkill.skillID,
              world.objects[objectSkill.sourceObjectID] != nil,
              let targetObject = world.objects[objectSkill.targetObjectID],
              objectSkill.damageType != .splash, objectSkill.damageType != .splash_endure else {
            return
        }

        let currentTime = CACurrentMediaTime()

        for effectReference in SkillEffectTable.effects(for: skillID) {
            let effect = MapSceneEffect(
                reference: effectReference,
                creationTime: currentTime,
                gridPosition: targetObject.gridPosition,
                worldPosition: targetObject.worldPosition,
                sourceWorldPosition: world.objects[objectSkill.sourceObjectID]?.worldPosition,
                targetObjectID: objectSkill.targetObjectID,
                sourceObjectID: objectSkill.sourceObjectID,
                ownerObjectID: nil,
                level: objectSkill.level,
                delay: TimeInterval(objectSkill.attackDelay) / 1000
            )
            addEffect(effect)
        }
    }

    private func addSkillSuccessEffects(for objectSkill: MapObjectSkill) {
        guard objectSkill.isSuccess,
              let skillID = objectSkill.skillID,
              let targetObject = world.objects[objectSkill.targetObjectID] else {
            return
        }

        let currentTime = CACurrentMediaTime()

        for effectReference in SkillEffectTable.successEffects(for: skillID) {
            let effect = MapSceneEffect(
                reference: effectReference,
                creationTime: currentTime,
                gridPosition: targetObject.gridPosition,
                worldPosition: targetObject.worldPosition,
                sourceWorldPosition: world.objects[objectSkill.sourceObjectID]?.worldPosition,
                targetObjectID: objectSkill.targetObjectID,
                sourceObjectID: objectSkill.sourceObjectID,
                ownerObjectID: nil,
                level: objectSkill.level
            )
            addEffect(effect)
        }
    }
}

// MARK: - Sound

extension MapScene {
    private func hitSoundName(for objectAction: MapObjectAction) -> String? {
        guard objectAction.damage > 0,
              let targetObject = world.objects[objectAction.targetObjectID] else {
            return nil
        }

        let sourceObject = world.objects[objectAction.sourceObjectID]
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
