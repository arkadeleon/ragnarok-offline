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
        let playerObject = objects[player.objectID] as? MapScenePlayerObject

        switch property {
        case .hp:
            gauges[player.objectID]?.hp = value
            playerObject?.hp = value
        case .maxhp:
            gauges[player.objectID]?.maxHp = value
            playerObject?.maxHp = value
        case .sp:
            gauges[player.objectID]?.sp = value
            playerObject?.sp = value
        case .maxsp:
            gauges[player.objectID]?.maxSp = value
            playerObject?.maxSp = value
        default:
            break
        }
    }

    public func onPlayerHealthPointsRecovered(recovered: Int, current: Int) {
        gauges[player.objectID]?.hp = current

        let playerObject = objects[player.objectID] as? MapScenePlayerObject
        playerObject?.hp = current

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
        gauges[player.objectID]?.sp = current

        let playerObject = objects[player.objectID] as? MapScenePlayerObject
        playerObject?.sp = current

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

        if let gauge = gauges[objectID] {
            gauge.hp = hp
            gauge.maxHp = maxHp
        } else if object.type == .monster {
            let gauge = Gauge(hp: hp, maxHp: maxHp, objectType: object.type)
            gauges[objectID] = gauge
        }
    }

    public func onMapObjectSpawned(object: MapObject, position: SIMD2<Int>, direction: Direction, headDirection: HeadDirection) {
        let mapObject = MapSceneMapObject.make(
            object: object,
            hp: object.hp,
            maxHp: object.maxHp,
            gridPosition: position,
            worldPosition: mapGrid.worldPosition(for: position),
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
            let mapObject = MapSceneMapObject.make(
                object: object,
                hp: object.hp,
                maxHp: object.maxHp,
                gridPosition: endPosition,
                worldPosition: mapGrid.worldPosition(for: endPosition),
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
        switch type {
        case .dead where objectID == player.objectID:
            if let object = objects[objectID] {
                object.perform(.die, completion: .indefinite)
            }
            gauges.removeValue(forKey: objectID)
            state.isPlayerDead = true
        default:
            objects.removeValue(forKey: objectID)
            gauges.removeValue(forKey: objectID)
        }
    }

    public func onMapObjectResurrected(objectID: GameObjectID) {
        if let object = objects[objectID] {
            object.perform(.idle, completion: .indefinite)
        }

        if objectID == player.objectID {
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
        let isVisible = effectState != .cloak

        if let mapObject = objects[objectID] {
            mapObject.bodyState = bodyState
            mapObject.healthState = healthState
            mapObject.effectState = effectState
        }

        if isVisible {
            if let object = objects[objectID], objectID == player.objectID {
                let sp = (object as? MapScenePlayerObject)?.sp
                let maxSp = (object as? MapScenePlayerObject)?.maxSp
                let gauge = Gauge(
                    hp: object.hp,
                    maxHp: object.maxHp,
                    sp: sp,
                    maxSp: maxSp,
                    objectType: object.type
                )
                gauges[objectID] = gauge
            }
        } else if objectID == player.objectID {
            gauges.removeValue(forKey: objectID)
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
            mapObject.weapon = value
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
                    weapon: sourceObject.weapon
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
            switch presentationActionType {
            case .attack1, .attack2, .attack3:
                if let targetObject = objects[objectAction.targetObjectID] {
                    sourceObject.setDirection(SpriteDirection(sourcePosition: sourceObject.gridPosition, targetPosition: targetObject.gridPosition))
                }
            default:
                break
            }

            sourceObject.perform(presentationActionType, completion: completion)
        }

        addArrowProjectileEffect(for: objectAction)
        addCombatTexts(for: objectAction, now: now)
        playSound(for: objectAction)
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

            for i in 0..<count {
                let combatText = CombatText(
                    creationTime: now,
                    target: target,
                    amount: damage / count,
                    delay: .milliseconds(objectSkill.attackDelay) + .milliseconds(200 * i)
                )
                addCombatText(combatText)
            }
        }

        addSkillBeforeHitEffects(for: objectSkill)
        addSkillHitEffects(for: objectSkill)
        addSkillEffects(for: objectSkill)
    }

    // MARK: - Map Item

    public func onItemSpawned(item: MapItem, position: SIMD2<Int>) {
        let mapItem = MapSceneMapItem(
            item: item,
            gridPosition: position,
            worldPosition: mapGrid.worldPosition(for: position)
        )
        items[item.objectID] = mapItem
    }

    public func onItemVanished(objectID: GameObjectID) {
        items.removeValue(forKey: objectID)
    }

    // MARK: - Other

    public func onGroundSkillCast(skillID: SkillID, position: SIMD2<Int>) {
        guard mapGrid.contains(position) else {
            return
        }

        let currentTime = CACurrentMediaTime()

        for effectReference in SkillEffectTable.effects(for: skillID) {
            addEffect(
                for: effectReference,
                creationTime: currentTime,
                gridPosition: position,
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
        object.worldPosition = mapGrid.worldPosition(for: gridPosition)
    }

    func moveObject(objectID: GameObjectID, startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) -> MetalMovement? {
        guard let object = objects[objectID] else {
            return nil
        }

        let now = ContinuousClock.now
        let movement = object.replanMovement(
            startPosition: startPosition,
            endPosition: endPosition,
            speed: object.speed,
            pathFinder: pathFinder,
            mapGrid: mapGrid,
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
}

// MARK: - Combat Text

extension MapScene {
    private func addCombatTexts(for objectAction: MapObjectAction, now: ContinuousClock.Instant) {
        let target = CombatText.Target(
            objectID: objectAction.targetObjectID,
            isPlayer: objects[objectAction.targetObjectID]?.type == .pc
        )

        switch objectAction.type {
        case .normal, .endure, .critical:
            let combatText = CombatText(
                creationTime: now,
                target: target,
                amount: objectAction.damage,
                delay: .milliseconds(objectAction.sourceSpeed)
            )
            addCombatText(combatText)

            if objectAction.damage2 > 0 {
                let combatText2 = CombatText(
                    creationTime: now,
                    target: target,
                    amount: objectAction.damage2,
                    delay: .milliseconds(objectAction.sourceSpeed) + .milliseconds(200 * 1.75)
                )
                addCombatText(combatText2)
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
            }
            if objectAction.damage2 > 0 {
                let combatText = CombatText(
                    creationTime: now,
                    target: target,
                    amount: objectAction.damage / count,
                    delay: .milliseconds(objectAction.sourceSpeed) + .milliseconds(200 / 2)
                )
                addCombatText(combatText)

                let combatText2 = CombatText(
                    creationTime: now,
                    target: target,
                    amount: objectAction.damage2,
                    delay: .milliseconds(objectAction.sourceSpeed) + .milliseconds(200 * 1.75)
                )
                addCombatText(combatText2)
            } else {
                let combatText = CombatText(
                    creationTime: now,
                    target: target,
                    amount: objectAction.damage / count,
                    delay: .milliseconds(objectAction.sourceSpeed) + .milliseconds(200)
                )
                addCombatText(combatText)
            }
        default:
            break
        }
    }

    private func addCombatText(_ combatText: CombatText) {
        guard let combatTextSpriteSet else {
            return
        }

        guard combatTextResources[combatText.id] == nil else {
            return
        }

        guard let startPosition = objects[combatText.target.objectID]?.worldPosition else {
            return
        }

        combatTextResources[combatText.id] = CombatTextRenderResource(
            device: renderer.device,
            combatText: combatText,
            startPosition: startPosition,
            spriteSet: combatTextSpriteSet
        )
    }
}

// MARK: - Effect

extension MapScene {
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
              ItemWeaponTypeTable.weaponType(for: sourceObject.weapon) == .w_bow else {
            return
        }

        addEffect(
            for: .name("ef_arrow_projectile"),
            creationTime: CACurrentMediaTime(),
            gridPosition: targetObject.gridPosition,
            sourceWorldPosition: sourceObject.worldPosition,
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
                    sourceWorldPosition: objects[objectSkill.sourceObjectID]?.worldPosition,
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
                    sourceWorldPosition: objects[objectSkill.sourceObjectID]?.worldPosition,
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
                sourceWorldPosition: objects[objectSkill.sourceObjectID]?.worldPosition,
                targetObjectID: objectSkill.targetObjectID,
                ownerObjectID: nil,
                delay: .milliseconds(objectSkill.attackDelay)
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
            worldPosition: mapGrid.worldPosition(for: gridPosition),
            sourceWorldPosition: sourceWorldPosition,
            targetObjectID: targetObjectID,
            delay: delay
        )
        addEffect(effect, ownerObjectID: ownerObjectID)
    }

    private func addEffect(_ effect: MapSceneEffect, ownerObjectID: GameObjectID?) {
        let effectID = effect.id
        if let ownerObjectID {
            objects[ownerObjectID]?.ownedEffects.append(effect)
        } else {
            effects[effectID] = effect
        }

        effectLoadTasks[effectID] = Task { [weak self] in
            guard let self else {
                return
            }
            defer {
                self.effectLoadTasks[effectID] = nil
            }

            do {
                guard let effectAssetStore else {
                    return
                }

                let assetGroup = try await effectAssetStore.assetGroup(for: effect.reference)
                guard !Task.isCancelled else {
                    return
                }

                for asset in assetGroup.assets {
                    if let soundName = asset.soundName {
                        audioPlayer.playSound(named: soundName, after: effect.delay)
                    }
                }

                effect.renderResourceGroup = EffectRenderResourceGroup(
                    device: renderer.device,
                    assetGroup: assetGroup,
                    creationTime: effect.creationTime,
                    delay: effect.delay,
                    worldPosition: effect.worldPosition,
                    sourceWorldPosition: effect.sourceWorldPosition
                )
            } catch {
                logger.warning("Metal map scene failed to load effect \(effect.reference): \(error)")
            }
        }
    }
}

// MARK: - Sound

extension MapScene {
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

        let sourceObject = objects[objectAction.sourceObjectID]
        let targetObject = objects[objectAction.targetObjectID]

        if let sourceObject, SpriteJob(rawValue: sourceObject.job).isPlayer {
            let weaponType = WeaponType(rawValue: sourceObject.weapon) ?? .w_fist
            let soundName = WeaponSoundTable.attackSoundNames(for: weaponType).randomElement()
            if let soundName {
                audioPlayer.playSound(named: soundName)
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
                    audioPlayer.playSound(named: hitSoundName)
                }
            }
        }
    }
}
