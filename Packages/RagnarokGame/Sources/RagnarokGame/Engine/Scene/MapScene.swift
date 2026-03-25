//
//  MapScene.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/3/27.
//

import CoreGraphics
import Foundation
import RagnarokConstants
import RagnarokModels
import RagnarokPackets
import RagnarokReality
import RagnarokResources
import RagnarokSprite
import SGLMath
import simd

@MainActor
public final class MapScene {
    let mapName: String
    let world: WorldResource
    let character: CharacterInfo
    let player: MapObject
    let playerPosition: SIMD2<Int>
    let resourceManager: ResourceManager
    weak let gameSession: GameSession?

    let mapGrid: MapGrid
    let state: MapSceneState
    private let backend: any MapSceneRuntimeBackend

    private let pathfinder: Pathfinder
    private let interactionResolver: MapInteractionResolver
    private var pendingArrivalAction: (@MainActor () -> Void)?
    private var arrivalTask: Task<Void, Never>?

    var cameraState: MapCameraState = .default {
        didSet {
            backend.applySnapshot(state)
        }
    }

    var renderBackend: any MapRenderBackend {
        backend
    }

    var realityViewBackend: (any MapRealityViewBackend)? {
        backend as? any MapRealityViewBackend
    }

    init(
        mapName: String,
        world: WorldResource,
        character: CharacterInfo,
        player: MapObject,
        playerPosition: SIMD2<Int>,
        resourceManager: ResourceManager,
        gameSession: GameSession
    ) {
        self.mapName = mapName
        self.world = world
        self.character = character
        self.player = player
        self.playerPosition = playerPosition
        self.resourceManager = resourceManager
        self.gameSession = gameSession

        self.mapGrid = MapGrid(gat: world.gat)

        let playerState = MapObjectState(
            id: player.objectID,
            object: player,
            gridPosition: playerPosition,
            hp: character.hp,
            maxHp: character.maxHp,
            sp: character.sp,
            maxSp: character.maxSp,
            isVisible: player.effectState != .cloak,
            presentation: MapObjectPresentationState(
                action: .idle,
                direction: .south,
                startedAt: .now
            )
        )
        self.state = MapSceneState(player: playerState)

        self.pathfinder = Pathfinder(mapGrid: self.mapGrid)
        self.interactionResolver = MapInteractionResolver(pathfinder: self.pathfinder)
        let backend = RealityKitMapBackend(resourceManager: resourceManager)
        self.backend = backend

        state.overlaySnapshot.anchors[player.objectID] = MapOverlayAnchor(
            id: player.objectID,
            hp: character.hp,
            maxHp: character.maxHp,
            sp: character.sp,
            maxSp: character.maxSp,
            objectType: player.type
        )

        backend.attach(scene: self)
    }

    func load(progress: Progress) async {
        await backend.load(progress: progress)
        backend.applySnapshot(state)
    }

    func unload() {
        backend.unload()
        backend.detach()
    }

    func handle(_ intent: MapInputIntent) {
        onMovementValueChanged(movementValue: intent.movementValue)
    }

    func handleInteraction(_ result: MapHitTestResult) {
        switch result {
        case .ground(let position):
            selectGround(at: position)
        case .mapObject(let objectID):
            handleMapObjectSelection(objectID: objectID)
        case .item(let objectID):
            gameSession?.pickUpItem(objectID: objectID)
        }
    }

    func selectGround(at position: SIMD2<Int>) {
        state.selection.selectedPosition = position
        backend.applySnapshot(state)
        gameSession?.requestMove(to: position)
    }

    func resetCamera() {
        cameraState.azimuth = 0
        cameraState.elevation = .pi / 4
    }

    func position(for gridPosition: SIMD2<Int>) -> SIMD3<Float> {
        let altitude = mapGrid[gridPosition].averageAltitude
        return [
            Float(gridPosition.x) + 0.5,
            altitude,
            -Float(gridPosition.y) - 0.5,
        ]
    }

    private func movementDuration(path: [SIMD2<Int>], speed: Int) -> Duration {
        var total: Duration = .zero
        for i in 1..<path.count {
            let dir = CharacterDirection(sourcePosition: path[i - 1], targetPosition: path[i])
            let stepMs = dir.isDiagonal ? Int((Double(speed) * sqrt(2)).rounded()) : speed
            total += .milliseconds(stepMs)
        }
        return total
    }

    private func playerMovementOrigin() -> SIMD2<Int> {
        state.player.movement?.to ?? state.player.gridPosition
    }

    private func onMovementValueChanged(movementValue: CGPoint) {
        let position = playerMovementOrigin()

        let joystickInput = SIMD2<Float>(
            Float(movementValue.x),
            Float(-movementValue.y)
        )
        let angle = -cameraState.azimuth
        let cosAngle = cos(angle)
        let sinAngle = sin(angle)
        let worldInput = SIMD2<Float>(
            joystickInput.x * cosAngle - joystickInput.y * sinAngle,
            joystickInput.x * sinAngle + joystickInput.y * cosAngle
        )

        let deadZone: Float = 15
        let stepLength: Float = 3
        let inputMagnitude = simd_length(worldInput)
        guard inputMagnitude > deadZone else {
            return
        }

        let normalizedDirection = worldInput / inputMagnitude
        let desiredOffset = normalizedDirection * stepLength
        let gridOffset = SIMD2<Int>(
            Int(desiredOffset.x.rounded()),
            Int(desiredOffset.y.rounded()),
        )

        if gridOffset != .zero {
            let newPosition = position &+ gridOffset
            gameSession?.requestMove(to: newPosition)
        }
    }

    func attackNearestMonster() {
        if let target = state.nearestMonster(fromPosition: state.player.gridPosition) {
            engageMonster(target)
        }
    }

    func useSkillOnNearestMonster(_ skill: SkillInfo) {
        guard skill.level > 0 else {
            return
        }

        if skill.isSelfOnlySkill {
            gameSession?.useSkill(
                skillID: skill.skillID,
                level: skill.level,
                onTarget: player.objectID
            )
            return
        }

        if let target = state.nearestMonster(fromPosition: state.player.gridPosition) {
            engageMonster(target, skill: skill)
        }
    }

    func pickUpNearestItem() {
        if let target = state.nearestItem(fromPosition: state.player.gridPosition) {
            engageItem(target)
        }
    }

    func talkToNearestNPC() {
        if let target = state.nearestNPC(fromPosition: state.player.gridPosition) {
            gameSession?.talkToNPC(npcID: target.id)
        }
    }

    private func handleMapObjectSelection(objectID: UInt32) {
        guard let target = state.objects[objectID] else {
            return
        }

        switch target.object.type {
        case .monster:
            engageMonster(target)
        case .npc:
            gameSession?.talkToNPC(npcID: target.id)
        default:
            break
        }
    }

    private func engageMonster(_ target: MapObjectState) {
        movePlayerToward(targetPosition: target.gridPosition, within: 1) {
            self.gameSession?.requestAction(._repeat, onTarget: target.id)
        }
    }

    private func engageMonster(_ target: MapObjectState, skill: SkillInfo) {
        let targetPosition = target.gridPosition
        let skillRange = max(skill.attackRange, 1)
        movePlayerToward(targetPosition: targetPosition, within: skillRange) {
            if skill.isGroundTargetedSkill {
                self.gameSession?.useSkill(
                    skillID: skill.skillID,
                    level: skill.level,
                    toGround: targetPosition
                )
            } else {
                self.gameSession?.useSkill(
                    skillID: skill.skillID,
                    level: skill.level,
                    onTarget: target.id
                )
            }
        }
    }

    private func engageItem(_ target: MapItemState) {
        movePlayerToward(targetPosition: target.gridPosition, within: 1) {
            self.gameSession?.pickUpItem(objectID: target.id)
        }
    }

    private func movePlayerToward(targetPosition: SIMD2<Int>, within range: Int, onArrival: @escaping @MainActor () -> Void) {
        let startPosition = state.player.gridPosition
        switch interactionResolver.decideMovement(from: startPosition, toward: targetPosition, within: range) {
        case .alreadyInRange:
            onArrival()
        case .moveTo(let destination):
            arrivalTask?.cancel()
            pendingArrivalAction = onArrival
            gameSession?.requestMove(to: destination)
        case .noPath:
            break
        }
    }
}

extension MapScene: MapEventHandlerProtocol {
    func onReceivePacket(_ packet: PACKET_ZC_PAR_CHANGE) {
        guard let sp = StatusProperty(rawValue: Int(packet.varID)) else {
            return
        }

        switch sp {
        case .hp:
            state.player.hp = Int(packet.count)
            state.overlaySnapshot.anchors[player.objectID]?.hp = Int(packet.count)
            Task {
                await backend.updateHealthAndSpellPoints(
                    for: player.objectID,
                    hp: Int(packet.count),
                    maxHp: nil,
                    sp: nil,
                    maxSp: nil
                )
            }
        case .maxhp:
            state.player.maxHp = Int(packet.count)
            state.overlaySnapshot.anchors[player.objectID]?.maxHp = Int(packet.count)
            Task {
                await backend.updateHealthAndSpellPoints(
                    for: player.objectID,
                    hp: nil,
                    maxHp: Int(packet.count),
                    sp: nil,
                    maxSp: nil
                )
            }
        case .sp:
            state.player.sp = Int(packet.count)
            state.overlaySnapshot.anchors[player.objectID]?.sp = Int(packet.count)
            Task {
                await backend.updateHealthAndSpellPoints(
                    for: player.objectID,
                    hp: nil,
                    maxHp: nil,
                    sp: Int(packet.count),
                    maxSp: nil
                )
            }
        case .maxsp:
            state.player.maxSp = Int(packet.count)
            state.overlaySnapshot.anchors[player.objectID]?.maxSp = Int(packet.count)
            Task {
                await backend.updateHealthAndSpellPoints(
                    for: player.objectID,
                    hp: nil,
                    maxHp: nil,
                    sp: nil,
                    maxSp: Int(packet.count)
                )
            }
        default:
            break
        }
    }

    func onReceivePacket(_ packet: PACKET_ZC_HP_INFO) {
        if state.player.id == packet.GID {
            state.player.hp = Int(packet.HP)
            state.player.maxHp = Int(packet.maxHP)
            state.overlaySnapshot.anchors[packet.GID]?.hp = Int(packet.HP)
            state.overlaySnapshot.anchors[packet.GID]?.maxHp = Int(packet.maxHP)
        } else {
            state.objects[packet.GID]?.hp = Int(packet.HP)
            state.objects[packet.GID]?.maxHp = Int(packet.maxHP)
            state.overlaySnapshot.anchors[packet.GID]?.hp = Int(packet.HP)
            state.overlaySnapshot.anchors[packet.GID]?.maxHp = Int(packet.maxHP)
        }

        Task {
            await backend.updateHealthAndSpellPoints(
                for: packet.GID,
                hp: Int(packet.HP),
                maxHp: Int(packet.maxHP),
                sp: nil,
                maxSp: nil
            )
        }
    }

    func onPlayerMoved(startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) {
        let now = ContinuousClock.now
        let path = pathfinder.findPath(from: startPosition, to: endPosition)
        let direction = path.count >= 2
            ? CharacterDirection(sourcePosition: path[0], targetPosition: path[1])
            : CharacterDirection(sourcePosition: startPosition, targetPosition: endPosition)
        let duration = movementDuration(path: path, speed: state.player.object.speed)
        state.player.gridPosition = endPosition
        state.player.movement = MapObjectMovementState(
            from: startPosition,
            to: endPosition,
            path: path,
            startedAt: now,
            duration: duration,
            direction: direction
        )
        state.player.presentation = MapObjectPresentationState(
            action: .walk,
            direction: direction,
            startedAt: now,
            duration: duration
        )
        if pendingArrivalAction != nil {
            arrivalTask?.cancel()
            arrivalTask = Task { @MainActor [weak self] in
                do {
                    try await Task.sleep(for: duration + .milliseconds(50))
                } catch {
                    return
                }
                guard let self else {
                    return
                }
                if let action = pendingArrivalAction {
                    pendingArrivalAction = nil
                    action()
                }
            }
        }

        Task {
            await backend.movePlayer(from: startPosition, to: endPosition)
        }
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
                direction: CharacterDirection(direction: direction),
                startedAt: .now
            )
        )

        if object.type == .monster {
            state.overlaySnapshot.anchors[object.objectID] = MapOverlayAnchor(
                id: object.objectID,
                hp: object.hp,
                maxHp: object.maxHp,
                objectType: object.type
            )
        }

        Task {
            await backend.spawnMapObject(
                object,
                position: position,
                direction: direction
            )
        }
    }

    func onMapObjectMoved(object: MapObject, startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) {
        let now = ContinuousClock.now
        let path = pathfinder.findPath(from: startPosition, to: endPosition)
        let direction = path.count >= 2
            ? CharacterDirection(sourcePosition: path[0], targetPosition: path[1])
            : CharacterDirection(sourcePosition: startPosition, targetPosition: endPosition)
        let duration = movementDuration(path: path, speed: object.speed)
        let movement = MapObjectMovementState(
            from: startPosition,
            to: endPosition,
            path: path,
            startedAt: now,
            duration: duration,
            direction: direction
        )
        let presentation = MapObjectPresentationState(
            action: .walk,
            direction: direction,
            startedAt: now,
            duration: duration
        )
        if state.objects[object.objectID] != nil {
            state.objects[object.objectID]?.gridPosition = endPosition
            state.objects[object.objectID]?.movement = movement
            state.objects[object.objectID]?.presentation = presentation
        } else {
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
                state.overlaySnapshot.anchors[object.objectID] = MapOverlayAnchor(
                    id: object.objectID,
                    hp: object.hp,
                    maxHp: object.maxHp,
                    objectType: object.type
                )
            }
        }

        Task {
            await backend.moveMapObject(
                object,
                startPosition: startPosition,
                endPosition: endPosition
            )
        }
    }

    func onMapObjectStopped(objectID: UInt32, position: SIMD2<Int>) {
        let now = ContinuousClock.now
        if state.player.id == objectID {
            state.player.gridPosition = position
            state.player.movement = nil
            state.player.presentation = MapObjectPresentationState(
                action: .idle,
                direction: state.player.presentation.direction,
                startedAt: now
            )

            if let action = pendingArrivalAction {
                arrivalTask?.cancel()
                arrivalTask = nil
                pendingArrivalAction = nil
                action()
            }
        } else {
            state.objects[objectID]?.gridPosition = position
            state.objects[objectID]?.movement = nil
            if let existing = state.objects[objectID] {
                state.objects[objectID]?.presentation = MapObjectPresentationState(
                    action: .idle,
                    direction: existing.presentation.direction,
                    startedAt: now
                )
            }
        }

        Task {
            await backend.stopMapObject(objectID: objectID, position: position)
        }
    }

    func onMapObjectVanished(objectID: UInt32) {
        state.objects.removeValue(forKey: objectID)
        state.overlaySnapshot.anchors.removeValue(forKey: objectID)

        Task {
            await backend.removeMapObject(objectID: objectID)
        }
    }

    func onMapObjectDirectionChanged(objectID: UInt32, direction: Direction, headDirection: HeadDirection) {
        if state.player.id == objectID {
            state.player.presentation.direction = CharacterDirection(direction: direction)
        } else {
            state.objects[objectID]?.presentation.direction = CharacterDirection(direction: direction)
        }
    }

    func onMapObjectStateChanged(objectID: UInt32, bodyState: StatusChangeOption1, healthState: StatusChangeOption2, effectState: StatusChangeOption) {
        let isVisible = effectState != .cloak

        if state.player.id == objectID {
            state.player.isVisible = isVisible
        } else {
            state.objects[objectID]?.isVisible = isVisible
        }

        if isVisible {
            if state.player.id == objectID {
                state.overlaySnapshot.anchors[objectID] = MapOverlayAnchor(
                    id: objectID,
                    hp: state.player.hp,
                    maxHp: state.player.maxHp,
                    sp: state.player.sp,
                    maxSp: state.player.maxSp,
                    objectType: state.player.object.type
                )
            } else if let objectState = state.objects[objectID], objectState.object.type == .monster {
                state.overlaySnapshot.anchors[objectID] = MapOverlayAnchor(
                    id: objectID,
                    hp: objectState.hp,
                    maxHp: objectState.maxHp,
                    objectType: objectState.object.type
                )
            }
        } else {
            state.overlaySnapshot.anchors.removeValue(forKey: objectID)
        }

        Task {
            await backend.setVisibility(forObjectID: objectID, isVisible: isVisible)
        }
    }

    func onMapObjectActionPerformed(objectAction: MapObjectAction) {
        let now = ContinuousClock.now
        let sourceMapObject = if state.player.id == objectAction.sourceObjectID {
            state.player.object
        } else {
            state.objects[objectAction.sourceObjectID]?.object
        }

        let presentationAction: CharacterActionType
        switch objectAction.type {
        case .sit_down:
            presentationAction = .sit
        case .stand_up:
            presentationAction = .idle
        case .pickup_item:
            presentationAction = .pickup
        case .normal, .endure, .critical, .multi_hit, .multi_hit_endure, .multi_hit_critical, .lucy_dodge:
            if let sourceMapObject {
                presentationAction = CharacterActionType.attackActionType(
                    forJobID: sourceMapObject.job,
                    gender: sourceMapObject.gender,
                    weapon: sourceMapObject.weapon
                )
            } else {
                presentationAction = .attack1
            }
        default:
            presentationAction = .attack1
        }

        let sourceDuration = Duration.milliseconds(objectAction.sourceSpeed)
        let sourceID = objectAction.sourceObjectID
        if state.player.id == sourceID {
            state.player.presentation = MapObjectPresentationState(
                action: presentationAction,
                direction: state.player.presentation.direction,
                startedAt: now,
                duration: sourceDuration
            )
        } else if state.objects[sourceID] != nil {
            let existingDirection = state.objects[sourceID]!.presentation.direction
            state.objects[sourceID]?.presentation = MapObjectPresentationState(
                action: presentationAction,
                direction: existingDirection,
                startedAt: now,
                duration: sourceDuration
            )
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

        Task {
            await backend.performMapObjectAction(objectAction)
        }
    }

    func onMapObjectSkillPerformed(_ packet: PACKET_ZC_NOTIFY_SKILL) {
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

        Task {
            await backend.performSkill(packet)
        }
    }

    func onItemSpawned(item: MapItem, position: SIMD2<Int>) {
        state.items[item.objectID] = MapItemState(
            id: item.objectID,
            item: item,
            gridPosition: position
        )

        Task {
            await backend.spawnItem(item, position: position)
        }
    }

    func onItemVanished(objectID: UInt32) {
        state.items.removeValue(forKey: objectID)

        Task {
            await backend.removeItem(objectID: objectID)
        }
    }
}
