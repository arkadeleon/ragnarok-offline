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
            updateObject(objectID: player.objectID)
        case .maxhp:
            state.overlay.gauges[player.objectID]?.maxHp = value
            playerObject?.maxHp = value
            updateObject(objectID: player.objectID)
        case .sp:
            state.overlay.gauges[player.objectID]?.sp = value
            playerObject?.sp = value
            updateObject(objectID: player.objectID)
        case .maxsp:
            state.overlay.gauges[player.objectID]?.maxSp = value
            playerObject?.maxSp = value
            updateObject(objectID: player.objectID)
        default:
            break
        }
    }

    public func onPlayerHealthPointsRecovered(recovered: Int, current: Int) {
        state.overlay.gauges[player.objectID]?.hp = current

        let playerObject = objectRegistry.object(for: player.objectID) as? MetalPlayerObject
        playerObject?.hp = current

        updateObject(objectID: player.objectID)

        let combatText = MetalCombatText(
            creationTime: .now,
            target: MetalCombatText.Target(objectID: player.objectID, isPlayer: true),
            amount: recovered,
            kind: .hpRecovery,
            delay: .zero
        )
        renderCombatText(combatText)
    }

    public func onPlayerSpellPointsRecovered(recovered: Int, current: Int) {
        state.overlay.gauges[player.objectID]?.sp = current

        let playerObject = objectRegistry.object(for: player.objectID) as? MetalPlayerObject
        playerObject?.sp = current

        updateObject(objectID: player.objectID)

        let combatText = MetalCombatText(
            creationTime: .now,
            target: MetalCombatText.Target(objectID: player.objectID, isPlayer: true),
            amount: recovered,
            kind: .spRecovery,
            delay: .zero
        )
        renderCombatText(combatText)
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

        updateObject(objectID: player.objectID)
    }

    public func onMapObjectHealthUpdated(objectID: GameObjectID, hp: Int, maxHp: Int) {
        if let metalObject = objectRegistry.object(for: objectID) {
            metalObject.hp = hp
            metalObject.maxHp = maxHp
            updateObject(objectID: objectID)
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

        addObject(
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

            addObject(
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

        _ = moveObject(
            objectID: object.objectID,
            startPosition: startPosition,
            endPosition: endPosition
        )
    }

    public func onMapObjectStopped(objectID: GameObjectID, position: SIMD2<Int>) {
        if objectRegistry.object(for: objectID) != nil {
            stopObject(objectID: objectID, at: position)
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
            performObjectAction(
                objectID: objectID,
                action: .die,
                completion: .indefinite
            )
            state.isPlayerDead = true
            state.overlay.gauges.removeValue(forKey: objectID)
        default:
            state.overlay.gauges.removeValue(forKey: objectID)
            objectRegistry.remove(objectID: objectID)
            spriteSnapshots.removeValue(forKey: objectID)
            refreshSpriteDrawables()
        }
    }

    public func onMapObjectResurrected(objectID: GameObjectID) {
        performObjectAction(
            objectID: objectID,
            action: .idle,
            completion: .indefinite
        )
        if objectID == player.objectID {
            state.isPlayerDead = false
        }
    }

    public func onMapObjectDirectionChanged(objectID: GameObjectID, direction: Direction, headDirection: HeadDirection) {
        turnObject(
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
            updateObject(objectID: objectID)
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

        updateObject(objectID: objectID)
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
            performObjectAction(
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

            performObjectAction(
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
                renderCombatText(combatText)
            }
        }

        addSkillHitEffects(for: objectSkill)
        addSkillEffects(for: objectSkill)
    }

    public func onItemSpawned(item: MapItem, position: SIMD2<Int>) {
        let metalItem = MetalMapItem(item: item, gridPosition: position)
        itemRegistry.add(metalItem)
        items[item.objectID] = metalItem
        refreshSpriteDrawables()
    }

    public func onItemVanished(objectID: GameObjectID) {
        itemRegistry.remove(objectID: objectID)
        items.removeValue(forKey: objectID)
        spriteSnapshots.removeValue(forKey: objectID)
        refreshSpriteDrawables()
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
    func addObject(objectID: GameObjectID, at gridPosition: SIMD2<Int>, direction: SpriteDirection, headDirection: SpriteHeadDirection) {
        guard let object = objectRegistry.object(for: objectID) else {
            return
        }
        object.gridPosition = gridPosition
        object.animationController.perform(.idle, completion: .indefinite)
        object.animationController.turn(direction: direction, headDirection: headDirection)
        object.presentation.worldPosition = mapGrid.worldPosition(for: gridPosition)
        refreshSpriteDrawables()
    }

    func updateObject(objectID: GameObjectID) {
        guard objectRegistry.object(for: objectID) != nil else {
            return
        }
        refreshSpriteDrawables()
    }

    func moveObject(objectID: GameObjectID, startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) -> MetalMovement? {
        guard let object = objectRegistry.object(for: objectID) else {
            return nil
        }

        let now = ContinuousClock.now
        let movement = object.movementController.replan(
            startPosition: startPosition,
            endPosition: endPosition,
            speed: object.speed,
            at: now
        )

        object.gridPosition = movement.currentPosition
        let remainingDuration = movement.remainingDuration(at: now)
        object.animationController.perform(
            .walk,
            completion: .after(remainingDuration, settledAction: .idle),
            at: now
        )
        object.animationController.setDirection(movement.finalDirection)

        refreshSpriteDrawables()
        if objectID == player.objectID {
            updateCameraTarget()
        }

        return movement
    }

    func stopObject(objectID: GameObjectID, at position: SIMD2<Int>) {
        if let object = objectRegistry.object(for: objectID) {
            object.gridPosition = position
            object.movementController.stop()
            object.animationController.perform(.idle, completion: .indefinite)
        }

        refreshSpriteDrawables()
        if objectID == player.objectID {
            updateCameraTarget()
        }
    }

    func turnObject(objectID: GameObjectID, direction: SpriteDirection, headDirection: SpriteHeadDirection) {
        guard let object = objectRegistry.object(for: objectID) else {
            return
        }

        object.animationController.turn(direction: direction, headDirection: headDirection)
        refreshSpriteDrawables()
    }

    func performObjectAction(objectID: GameObjectID, action: SpriteActionType, completion: MetalAnimationCompletion) {
        guard let object = objectRegistry.object(for: objectID) else {
            return
        }

        object.animationController.perform(action, completion: completion)
        refreshSpriteDrawables()
    }

    private func afterAttackAction(for object: MetalMapObject?) -> SpriteActionType {
        guard let object else {
            return .idle
        }

        let availableActionTypes = SpriteActionType.availableActionTypes(forJobID: object.job)
        return availableActionTypes.contains(.readyToAttack) ? .readyToAttack : .idle
    }
}

// MARK: - Combat Text

extension MetalMapScene {
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
            renderCombatText(combatText)

            if objectAction.damage2 > 0 {
                let combatText2 = MetalCombatText(
                    creationTime: now,
                    target: target,
                    amount: objectAction.damage2,
                    delay: .milliseconds(objectAction.sourceSpeed) + .milliseconds(200 * 1.75)
                )
                renderCombatText(combatText2)
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
                renderCombatText(combatText)
            }
            if objectAction.damage2 > 0 {
                let combatText = MetalCombatText(
                    creationTime: now,
                    target: target,
                    amount: objectAction.damage / count,
                    delay: .milliseconds(objectAction.sourceSpeed) + .milliseconds(200 / 2)
                )
                renderCombatText(combatText)

                let combatText2 = MetalCombatText(
                    creationTime: now,
                    target: target,
                    amount: objectAction.damage2,
                    delay: .milliseconds(objectAction.sourceSpeed) + .milliseconds(200 * 1.75)
                )
                renderCombatText(combatText2)
            } else {
                let combatText = MetalCombatText(
                    creationTime: now,
                    target: target,
                    amount: objectAction.damage / count,
                    delay: .milliseconds(objectAction.sourceSpeed) + .milliseconds(200)
                )
                renderCombatText(combatText)
            }
        default:
            break
        }
    }

    private func renderCombatText(_ combatText: MetalCombatText) {
        guard let combatTextSpriteSet else {
            return
        }

        guard renderer.combatTextResources[combatText.id] == nil else {
            return
        }

        guard let startPosition = spriteSnapshots[combatText.target.objectID]?.worldPosition
            ?? fallbackWorldPosition(for: combatText.target.objectID) else {
            return
        }

        renderer.combatTextResources[combatText.id] = CombatTextRenderResource(
            device: renderer.device,
            combatText: combatText,
            startPosition: startPosition,
            spriteSet: combatTextSpriteSet
        )
    }

    private func fallbackWorldPosition(for objectID: GameObjectID) -> SIMD3<Float>? {
        if let object = objectRegistry.object(for: objectID) {
            return object.presentation.worldPosition
        } else {
            return nil
        }
    }
}

// MARK: - Effect

extension MetalMapScene {
    private func addSkillHitEffects(for objectSkill: MapObjectSkill) {
        guard objectSkill.damage > 0,
              let skillID = objectSkill.skillID,
              let targetPosition = objectRegistry.object(for: objectSkill.targetObjectID)?.gridPosition else {
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
              let targetPosition = objectRegistry.object(for: objectSkill.targetObjectID)?.gridPosition,
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
            renderEffect(effect)
        }
    }

    private func renderEffect(_ effect: MetalSkillEffect) {
        if let soundName = effect.effectDefinition.soundName {
            audioPlayer.playSound(named: soundName, after: effect.delay)
        }

        let worldPosition = mapGrid.worldPosition(for: effect.gridPosition)
        let effectID = effect.id

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

                let asset = try await effectAssetStore.asset(for: effect.effectDefinition)

                renderer.effectResources[effectID] = try STREffectRenderResource(
                    device: renderer.device,
                    effect: effect,
                    strEffect: asset.effect,
                    textures: asset.textures,
                    worldPosition: worldPosition
                )
            } catch {
                logger.warning("Metal map scene failed to load effect \(effect.effectID): \(error)")
            }
        }
    }
}

// MARK: - Sound

extension MetalMapScene {
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
