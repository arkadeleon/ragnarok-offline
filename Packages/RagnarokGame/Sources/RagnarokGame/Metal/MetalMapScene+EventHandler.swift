//
//  MetalMapScene+EventHandler.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import Foundation
import QuartzCore
import RagnarokConstants
import RagnarokEffects
import RagnarokModels
import RagnarokRenderers
import RagnarokSprite
import simd

extension MetalMapScene {
    public func onPlayerStatusChanged(property: StatusProperty, value: Int) {
        let playerObject = objects[player.objectID] as? MetalPlayerObject

        switch property {
        case .hp:
            state.overlay.gauges[player.objectID]?.hp = value
            playerObject?.hp = value
            refreshSpriteDrawables()
        case .maxhp:
            state.overlay.gauges[player.objectID]?.maxHp = value
            playerObject?.maxHp = value
            refreshSpriteDrawables()
        case .sp:
            state.overlay.gauges[player.objectID]?.sp = value
            playerObject?.sp = value
            refreshSpriteDrawables()
        case .maxsp:
            state.overlay.gauges[player.objectID]?.maxSp = value
            playerObject?.maxSp = value
            refreshSpriteDrawables()
        default:
            break
        }
    }

    public func onPlayerHealthPointsRecovered(recovered: Int, current: Int) {
        state.overlay.gauges[player.objectID]?.hp = current

        let playerObject = objects[player.objectID] as? MetalPlayerObject
        playerObject?.hp = current

        refreshSpriteDrawables()

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

        let playerObject = objects[player.objectID] as? MetalPlayerObject
        playerObject?.sp = current

        refreshSpriteDrawables()

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

        refreshSpriteDrawables()
    }

    public func onMapObjectHealthUpdated(objectID: GameObjectID, hp: Int, maxHp: Int) {
        guard let object = objects[objectID] else {
            return
        }

        object.hp = hp
        object.maxHp = maxHp

        refreshSpriteDrawables()

        if var gauge = state.overlay.gauges[objectID] {
            gauge.hp = hp
            gauge.maxHp = maxHp
            state.overlay.gauges[objectID] = gauge
        } else if object.type == .monster {
            let gauge = MetalGaugeOverlay(
                id: objectID,
                hp: hp,
                maxHp: maxHp,
                objectType: object.type
            )
            state.overlay.gauges[objectID] = gauge
        }
    }

    public func onMapObjectSpawned(object: MapObject, position: SIMD2<Int>, direction: Direction, headDirection: HeadDirection) {
        let metalObject = MetalMapObject.make(
            object: object,
            hp: object.hp,
            maxHp: object.maxHp,
            gridPosition: position,
            worldPosition: mapGrid.worldPosition(for: position),
            direction: SpriteDirection(direction: direction),
            headDirection: SpriteHeadDirection(headDirection: headDirection)
        )
        objects[metalObject.objectID] = metalObject

        addObject(
            objectID: object.objectID,
            at: position,
            direction: SpriteDirection(direction: direction),
            headDirection: SpriteHeadDirection(headDirection: headDirection)
        )

        if object.job == 45 { // JT_WARPNPC
            addEffects(
                forEffectID: 321, // EF_WARPZONE2
                creationTime: CACurrentMediaTime(),
                gridPosition: position,
                attachedObjectID: object.objectID,
                ownerObjectID: object.objectID,
                delay: 0
            )
        }
    }

    public func onMapObjectMoved(object: MapObject, startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) {
        let isNew = objects[object.objectID] == nil

        if isNew {
            let metalObject = MetalMapObject.make(
                object: object,
                hp: object.hp,
                maxHp: object.maxHp,
                gridPosition: endPosition,
                worldPosition: mapGrid.worldPosition(for: endPosition),
                direction: SpriteDirection(sourcePosition: startPosition, targetPosition: endPosition),
                headDirection: .lookForward
            )
            objects[metalObject.objectID] = metalObject

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
                refreshSpriteDrawables()
            }

            state.isPlayerDead = true
            state.overlay.gauges.removeValue(forKey: objectID)
        default:
            state.overlay.gauges.removeValue(forKey: objectID)
            objects.removeValue(forKey: objectID)
            refreshSpriteDrawables()
        }
    }

    public func onMapObjectResurrected(objectID: GameObjectID) {
        if let object = objects[objectID] {
            object.perform(.idle, completion: .indefinite)
            refreshSpriteDrawables()
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

        refreshSpriteDrawables()
    }

    public func onMapObjectStateChanged(objectID: GameObjectID, bodyState: StatusChangeOption1, healthState: StatusChangeOption2, effectState: StatusChangeOption) {
        let isVisible = effectState != .cloak

        if let metalObject = objects[objectID] {
            metalObject.bodyState = bodyState
            metalObject.healthState = healthState
            metalObject.effectState = effectState
            refreshSpriteDrawables()
        }

        if isVisible {
            if let object = objects[objectID], objectID == player.objectID {
                let sp = (object as? MetalPlayerObject)?.sp
                let maxSp = (object as? MetalPlayerObject)?.maxSp
                let gauge = MetalGaugeOverlay(
                    id: objectID,
                    hp: object.hp,
                    maxHp: object.maxHp,
                    sp: sp,
                    maxSp: maxSp,
                    objectType: object.type
                )
                state.overlay.gauges[objectID] = gauge
            }
        } else if objectID == player.objectID {
            state.overlay.gauges.removeValue(forKey: objectID)
        }
    }

    public func onMapObjectSpriteChanged(objectID: GameObjectID, look: Look, value: Int, value2: Int) {
        guard let metalObject = objects[objectID] else {
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

        refreshSpriteDrawables()
    }

    public func onMapObjectActionPerformed(objectAction: MapObjectAction) {
        let now = ContinuousClock.now

        let sourceID = objectAction.sourceObjectID
        let sourceObject = objects[sourceID]

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

        if let sourceObject {
            sourceObject.perform(presentationAction, completion: completion)
            refreshSpriteDrawables()
        }

        addCombatTexts(for: objectAction, now: now)
        playSound(for: objectAction)
    }

    public func onMapObjectSkillPerformed(objectSkill: MapObjectSkill) {
        let now = ContinuousClock.now

        if let sourceObject = objects[objectSkill.sourceObjectID] {
            let availableActionTypes = SpriteActionType.availableActionTypes(forJobID: sourceObject.job)
            let action: SpriteActionType = availableActionTypes.contains(.skill) ? .skill : .attack1
            let duration = Duration.milliseconds(objectSkill.attackDelay)
            let settledAction: SpriteActionType = availableActionTypes.contains(.readyToAttack) ? .readyToAttack : .idle

            sourceObject.perform(action, completion: .after(duration, settledAction: settledAction))
            refreshSpriteDrawables()
        }

        if objectSkill.damage >= 0 {
            let count = objectSkill.count
            let damage = objectSkill.damage
            let target = MetalCombatText.Target(
                objectID: objectSkill.targetObjectID,
                isPlayer: objects[objectSkill.targetObjectID]?.type == .pc
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
        let metalItem = MetalMapItem(
            item: item,
            gridPosition: position,
            worldPosition: mapGrid.worldPosition(for: position)
        )
        items[item.objectID] = metalItem
        refreshSpriteDrawables()
    }

    public func onItemVanished(objectID: GameObjectID) {
        items.removeValue(forKey: objectID)
        refreshSpriteDrawables()
    }

    public func onGroundSkillCast(skillID: SkillID, position: SIMD2<Int>) {
        guard mapGrid.contains(position) else {
            return
        }

        let currentTime = CACurrentMediaTime()

        for effectID in SkillEffectTable.effectIDs(for: skillID) {
            addEffects(
                forEffectID: effectID,
                creationTime: currentTime,
                gridPosition: position,
                attachedObjectID: nil,
                ownerObjectID: nil,
                delay: 0
            )
        }
    }
}

extension MetalMapScene {
    func addObject(objectID: GameObjectID, at gridPosition: SIMD2<Int>, direction: SpriteDirection, headDirection: SpriteHeadDirection) {
        guard let object = objects[objectID] else {
            return
        }
        object.gridPosition = gridPosition
        object.perform(.idle, completion: .indefinite)
        object.turn(direction: direction, headDirection: headDirection)
        object.worldPosition = mapGrid.worldPosition(for: gridPosition)
        refreshSpriteDrawables()
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
            completion: .after(remainingDuration, settledAction: .idle),
            at: now
        )
        object.setDirection(movement.finalDirection)

        refreshSpriteDrawables()
        if objectID == player.objectID {
            updateCameraTarget()
        }

        return movement
    }

    func stopObject(objectID: GameObjectID, at position: SIMD2<Int>) {
        if let object = objects[objectID] {
            object.gridPosition = position
            object.stopMovement()
            object.perform(.idle, completion: .indefinite)
        }

        refreshSpriteDrawables()
        if objectID == player.objectID {
            updateCameraTarget()
        }
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
            isPlayer: objects[objectAction.targetObjectID]?.type == .pc
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

extension MetalMapScene {
    private func addSkillHitEffects(for objectSkill: MapObjectSkill) {
        guard objectSkill.damage > 0,
              let skillID = objectSkill.skillID,
              let targetPosition = objects[objectSkill.targetObjectID]?.gridPosition else {
            return
        }

        let currentTime = CACurrentMediaTime()
        let count = max(1, objectSkill.count)

        for hitEffectID in SkillEffectTable.hitEffectIDs(for: skillID) {
            for i in 0..<count {
                addEffects(
                    forEffectID: hitEffectID,
                    creationTime: currentTime,
                    gridPosition: targetPosition,
                    attachedObjectID: objectSkill.targetObjectID,
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

        for effectID in SkillEffectTable.effectIDs(for: skillID) {
            addEffects(
                forEffectID: effectID,
                creationTime: currentTime,
                gridPosition: targetPosition,
                attachedObjectID: objectSkill.targetObjectID,
                ownerObjectID: nil,
                delay: .milliseconds(objectSkill.attackDelay)
            )
        }
    }

    private func addEffects(
        forEffectID effectID: Int,
        creationTime: TimeInterval,
        gridPosition: SIMD2<Int>,
        attachedObjectID: GameObjectID?,
        ownerObjectID: GameObjectID?,
        delay: TimeInterval
    ) {
        let definitions = EffectTable.definitions(forEffectID: effectID)
        for definition in definitions {
            let effect = MetalMapEffect(
                effectID: effectID,
                effectDefinition: definition.resolved(),
                creationTime: creationTime,
                gridPosition: gridPosition,
                attachedObjectID: attachedObjectID,
                delay: delay
            )
            addEffect(effect, ownerObjectID: ownerObjectID)
        }
    }

    private func addEffect(_ effect: MetalMapEffect, ownerObjectID: GameObjectID?) {
        if let soundName = effect.effectDefinition.soundName {
            audioPlayer.playSound(named: soundName, after: effect.delay)
        }

        let effectID = effect.id
        let effectWorldPosition = mapGrid.worldPosition(for: effect.gridPosition)
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

                let asset = try await effectAssetStore.asset(for: effect.effectDefinition)
                guard !Task.isCancelled else {
                    return
                }

                switch asset {
                case .`3D`(let asset):
                    let worldPosition = effect.attachedObjectID.flatMap { objects[$0]?.worldPosition } ?? effectWorldPosition
                    var renderResources: [MetalEffectRenderResource] = []
                    for duplicateID in 0..<max(asset.definition.duplicateCount, 1) {
                        let delay = effect.delay
                            + asset.definition.delayStart
                            + asset.definition.delay
                            + asset.definition.delayOffset
                            + asset.definition.delayLate
                            + asset.definition.duplicateInterval * TimeInterval(duplicateID)
                            + asset.definition.delayOffsetDelta * TimeInterval(duplicateID)
                            + asset.definition.delayLateDelta * TimeInterval(duplicateID)
                        let renderResource = Effect3DRenderResource(
                            device: renderer.device,
                            asset: asset,
                            worldPosition: worldPosition,
                            creationTime: effect.creationTime,
                            delay: delay,
                            duplicateID: duplicateID
                        )
                        renderResources.append(.`3D`(renderResource))
                    }
                    effect.renderResources = renderResources
                case .cylinder(let asset):
                    let worldPosition = effect.attachedObjectID.flatMap { objects[$0]?.worldPosition } ?? effectWorldPosition
                    var renderResources: [MetalEffectRenderResource] = []
                    for duplicateID in 0..<max(asset.definition.duplicateCount, 1) {
                        let delay = effect.delay
                            + asset.definition.delayStart
                            + asset.definition.delayOffset
                            + asset.definition.delayLate
                            + asset.definition.duplicateInterval * TimeInterval(duplicateID)
                            + asset.definition.delayOffsetDelta * TimeInterval(duplicateID)
                            + asset.definition.delayLateDelta * TimeInterval(duplicateID)
                        let renderResource = CylinderEffectRenderResource(
                            device: renderer.device,
                            asset: asset,
                            worldPosition: worldPosition,
                            creationTime: effect.creationTime,
                            delay: delay
                        )
                        renderResources.append(.cylinder(renderResource))
                    }
                    effect.renderResources = renderResources
                case .str(let asset):
                    let renderResource = STREffectRenderResource(
                        device: renderer.device,
                        asset: asset,
                        spritePosition: [
                            Float(effect.gridPosition.x),
                            Float(effect.gridPosition.y),
                            effectWorldPosition.y,
                        ],
                        creationTime: effect.creationTime,
                        delay: effect.delay
                    )
                    effect.renderResources = [.str(renderResource)]
                }
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
