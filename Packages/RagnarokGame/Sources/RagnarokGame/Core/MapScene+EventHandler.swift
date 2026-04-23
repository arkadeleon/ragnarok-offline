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

    func onPlayerMoved(startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) {
        let now = ContinuousClock.now
        let path = pathfinder.findPath(from: startPosition, to: endPosition)
        let direction = if path.count >= 2 {
            SpriteDirection(sourcePosition: path[0], targetPosition: path[1])
        } else {
            SpriteDirection(sourcePosition: startPosition, targetPosition: endPosition)
        }
        let duration = movementDuration(path: path, speed: state.player.object.speed)
        let animationElapsedOffset = if let existingMovement = state.player.movement {
            existingMovement.animationElapsedOffset + existingMovement.startTime.duration(to: now)
        } else {
            Duration.zero
        }

        state.player.gridPosition = endPosition
        state.player.movement = MapObjectMovementState(
            from: startPosition,
            to: endPosition,
            path: path,
            startTime: now,
            duration: duration,
            direction: direction,
            animationElapsedOffset: animationElapsedOffset
        )
        state.player.presentation = MapObjectPresentationState(
            action: .walk,
            direction: direction,
            headDirection: state.player.presentation.headDirection,
            startTime: now,
            duration: duration
        )

        if pendingArrivalAction != nil {
            arrivalTask?.cancel()
            arrivalTask = Task { @MainActor [weak self] in
                try await Task.sleep(for: duration + .milliseconds(50))
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

        if state.player.id == packet.GID {
            state.player.hp = hp
            state.player.maxHp = maxHp
            state.overlay.gauges[objectID]?.hp = hp
            state.overlay.gauges[objectID]?.maxHp = maxHp
        } else {
            state.objects[objectID]?.hp = hp
            state.objects[objectID]?.maxHp = maxHp
            state.overlay.gauges[objectID]?.hp = hp
            state.overlay.gauges[objectID]?.maxHp = maxHp
        }

        applySnapshot()
    }

    func onMapObjectSpawned(object: MapObject, position: SIMD2<Int>, direction: Direction, headDirection: HeadDirection) {
        state.objects[object.objectID] = MapObjectState(
            id: object.objectID,
            object: object,
            gridPosition: position,
            hp: object.hp,
            maxHp: object.maxHp,
            isVisible: object.effectState != .cloak,
            presentation: MapObjectPresentationState(
                action: .idle,
                direction: SpriteDirection(direction: direction),
                headDirection: SpriteHeadDirection(headDirection: headDirection),
                startTime: .now
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
        let path = pathfinder.findPath(from: startPosition, to: endPosition)
        let direction = if path.count >= 2 {
            SpriteDirection(sourcePosition: path[0], targetPosition: path[1])
        } else {
            SpriteDirection(sourcePosition: startPosition, targetPosition: endPosition)
        }
        let duration = movementDuration(path: path, speed: object.speed)
        let movement = MapObjectMovementState(
            from: startPosition,
            to: endPosition,
            path: path,
            startTime: now,
            duration: duration,
            direction: direction
        )

        if var objectState = state.objects[object.objectID] {
            let presentation = MapObjectPresentationState(
                action: .walk,
                direction: direction,
                headDirection: objectState.presentation.headDirection,
                startTime: now,
                duration: duration
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
                duration: duration
            )
            state.objects[object.objectID] = MapObjectState(
                id: object.objectID,
                object: object,
                gridPosition: endPosition,
                hp: object.hp,
                maxHp: object.maxHp,
                isVisible: object.effectState != .cloak,
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

        if state.player.id == objectID {
            state.player.gridPosition = position
            state.player.movement = nil
            state.player.presentation = MapObjectPresentationState(
                action: .idle,
                direction: state.player.presentation.direction,
                headDirection: state.player.presentation.headDirection,
                startTime: now
            )

            if let action = pendingArrivalAction {
                arrivalTask?.cancel()
                arrivalTask = nil
                pendingArrivalAction = nil
                action()
            }
        } else if var objectState = state.objects[objectID] {
            objectState.gridPosition = position
            objectState.movement = nil
            objectState.presentation = MapObjectPresentationState(
                action: .idle,
                direction: objectState.presentation.direction,
                headDirection: objectState.presentation.headDirection,
                startTime: now
            )
            state.objects[objectID] = objectState
        }

        applySnapshot()
    }

    func onMapObjectVanished(objectID: GameObjectID) {
        state.objects.removeValue(forKey: objectID)
        state.overlay.gauges.removeValue(forKey: objectID)

        applySnapshot()
    }

    func onMapObjectDirectionChanged(objectID: GameObjectID, direction: Direction, headDirection: HeadDirection) {
        if state.player.id == objectID {
            state.player.presentation.direction = SpriteDirection(direction: direction)
            state.player.presentation.headDirection = SpriteHeadDirection(headDirection: headDirection)
        } else if var objectState = state.objects[objectID] {
            objectState.presentation.direction = SpriteDirection(direction: direction)
            objectState.presentation.headDirection = SpriteHeadDirection(headDirection: headDirection)
            state.objects[objectID] = objectState
        }

        applySnapshot()
    }

    func onMapObjectStateChanged(objectID: GameObjectID, bodyState: StatusChangeOption1, healthState: StatusChangeOption2, effectState: StatusChangeOption) {
        let isVisible = effectState != .cloak

        if state.player.id == objectID {
            state.player.isVisible = isVisible
        } else {
            state.objects[objectID]?.isVisible = isVisible
        }

        if isVisible {
            if state.player.id == objectID {
                state.overlay.gauges[objectID] = MapGaugeOverlay(
                    id: objectID,
                    hp: state.player.hp,
                    maxHp: state.player.maxHp,
                    sp: state.player.sp,
                    maxSp: state.player.maxSp,
                    objectType: state.player.object.type
                )
            } else if let objectState = state.objects[objectID], objectState.object.type == .monster {
                state.overlay.gauges[objectID] = MapGaugeOverlay(
                    id: objectID,
                    hp: objectState.hp,
                    maxHp: objectState.maxHp,
                    objectType: objectState.object.type
                )
            }
        } else {
            state.overlay.gauges.removeValue(forKey: objectID)
        }

        applySnapshot()
    }

    func onMapObjectActionPerformed(objectAction: MapObjectAction) {
        let now = ContinuousClock.now

        let sourceID = objectAction.sourceObjectID
        let sourceMapObject = state.object(for: sourceID)?.object

        let presentationAction: SpriteActionType = switch objectAction.type {
        case .sit_down:
            .sit
        case .stand_up:
            .idle
        case .pickup_item:
            .pickup
        case .normal, .endure, .critical, .multi_hit, .multi_hit_endure, .multi_hit_critical, .lucy_dodge:
            if let sourceMapObject {
                SpriteActionType.attackActionType(
                    forJobID: sourceMapObject.job,
                    gender: sourceMapObject.gender,
                    weapon: sourceMapObject.weapon
                )
            } else {
                .attack1
            }
        default:
            .attack1
        }

        let sourceDuration = Duration.milliseconds(objectAction.sourceSpeed)
        if state.player.id == sourceID {
            state.player.presentation = MapObjectPresentationState(
                action: presentationAction,
                direction: state.player.presentation.direction,
                headDirection: state.player.presentation.headDirection,
                startTime: now,
                duration: sourceDuration
            )
        } else if var objectState = state.objects[sourceID] {
            objectState.presentation = MapObjectPresentationState(
                action: presentationAction,
                direction: objectState.presentation.direction,
                headDirection: objectState.presentation.headDirection,
                startTime: now,
                duration: sourceDuration
            )
            state.objects[sourceID] = objectState
        }

        switch objectAction.type {
        case .normal, .endure, .critical:
            let damageEffect = MapDamageEffect(
                targetObjectID: objectAction.targetObjectID,
                amount: objectAction.damage,
                delay: TimeInterval(objectAction.sourceSpeed)
            )
            state.damageEffects.append(damageEffect)

            if objectAction.damage2 > 0 {
                let damageEffect2 = MapDamageEffect(
                    targetObjectID: objectAction.targetObjectID,
                    amount: objectAction.damage2,
                    delay: TimeInterval(objectAction.sourceSpeed) + 200 * 1.75
                )
                state.damageEffects.append(damageEffect2)
            }
        case .multi_hit, .multi_hit_endure, .multi_hit_critical:
            let count = objectAction.damage > 1 ? 2 : 1
            if count == 2 {
                let damageEffect = MapDamageEffect(
                    targetObjectID: objectAction.targetObjectID,
                    amount: objectAction.damage / count,
                    delay: TimeInterval(objectAction.sourceSpeed)
                )
                state.damageEffects.append(damageEffect)
            }
            if objectAction.damage2 > 0 {
                let damageEffect = MapDamageEffect(
                    targetObjectID: objectAction.targetObjectID,
                    amount: objectAction.damage / count,
                    delay: TimeInterval(objectAction.sourceSpeed) + 200 / 2
                )
                state.damageEffects.append(damageEffect)

                let damageEffect2 = MapDamageEffect(
                    targetObjectID: objectAction.targetObjectID,
                    amount: objectAction.damage2,
                    delay: TimeInterval(objectAction.sourceSpeed) + 200 * 1.75
                )
                state.damageEffects.append(damageEffect2)
            } else {
                let damageEffect = MapDamageEffect(
                    targetObjectID: objectAction.targetObjectID,
                    amount: objectAction.damage / count,
                    delay: TimeInterval(objectAction.sourceSpeed) + 200
                )
                state.damageEffects.append(damageEffect)
            }
        default:
            break
        }

        applySnapshot()

        playSound(for: objectAction)
    }

    func onMapObjectSkillPerformed(_ packet: PACKET_ZC_NOTIFY_SKILL) {
        let objectID = packet.AID

        let now = ContinuousClock.now
        let sourceMapObject = state.object(for: objectID)?.object

        if let sourceMapObject {
            let availableActionTypes = SpriteActionType.availableActionTypes(forJobID: sourceMapObject.job)
            let action: SpriteActionType = availableActionTypes.contains(.skill) ? .skill : .attack1
            let duration = Duration.milliseconds(Int(packet.attackMT))

            if state.player.id == objectID {
                state.player.presentation = MapObjectPresentationState(
                    action: action,
                    direction: state.player.presentation.direction,
                    headDirection: state.player.presentation.headDirection,
                    startTime: now,
                    duration: duration
                )
            } else if var objectState = state.objects[objectID] {
                objectState.presentation = MapObjectPresentationState(
                    action: action,
                    direction: objectState.presentation.direction,
                    headDirection: objectState.presentation.headDirection,
                    startTime: now,
                    duration: duration
                )
                state.objects[objectID] = objectState
            }
        }

        if packet.damage >= 0 {
            let count = Int(packet.count)
            let damage = Int(packet.damage)
            for i in 0..<count {
                let damageEffect = MapDamageEffect(
                    targetObjectID: packet.targetID,
                    amount: damage / count,
                    delay: TimeInterval(packet.attackMT) + TimeInterval(200 * i)
                )
                state.damageEffects.append(damageEffect)
            }
        }

        applySnapshot()
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
}

extension MapScene {
    func movementDuration(path: [SIMD2<Int>], speed: Int) -> Duration {
        var total: Duration = .zero
        for i in 1..<path.count {
            let direction = SpriteDirection(sourcePosition: path[i - 1], targetPosition: path[i])
            let stepMs = direction.isDiagonal ? Int((Double(speed) * sqrt(2)).rounded()) : speed
            total += .milliseconds(stepMs)
        }
        return total
    }

    func playSound(for objectAction: MapObjectAction) {
        let isAttackAction = switch objectAction.type {
        case .normal, .endure, .critical, .multi_hit, .multi_hit_endure, .multi_hit_critical, .lucy_dodge:
            true
        default:
            false
        }

        guard isAttackAction else {
            return
        }

        let sourceMapObject = state.object(for: objectAction.sourceObjectID)?.object
        let targetMapObject = state.object(for: objectAction.targetObjectID)?.object

        if let sourceMapObject, SpriteJob(rawValue: sourceMapObject.job).isPlayer {
            let weaponType = WeaponType(rawValue: sourceMapObject.weapon) ?? .w_fist
            let soundName = WeaponSoundTable.attackSoundNames(for: weaponType).randomElement()
            if let soundName {
                renderBackend.playSound(named: soundName, on: objectAction.sourceObjectID)
            }
        }

        if let targetMapObject, objectAction.damage > 0 {
            let targetJob = SpriteJob(rawValue: targetMapObject.job)

            let hitSoundName: String?
            if targetJob.isPlayer {
                hitSoundName = JobHitSoundTable.hitSoundNames(forJob: targetMapObject.job).randomElement()
            } else if let sourceMapObject, SpriteJob(rawValue: sourceMapObject.job).isPlayer {
                let weaponType = WeaponType(rawValue: sourceMapObject.weapon) ?? .w_fist
                let weaponHitSoundName = WeaponHitSoundTable.hitSoundNames(for: weaponType).randomElement()
                hitSoundName = weaponHitSoundName ?? JobHitSoundTable.hitSoundNames(forJob: targetMapObject.job).randomElement()
            } else {
                hitSoundName = JobHitSoundTable.hitSoundNames(forJob: targetMapObject.job).randomElement()
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
