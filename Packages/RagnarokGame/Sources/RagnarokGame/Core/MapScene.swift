//
//  MapScene.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/3/27.
//

import CoreGraphics
import Foundation
import RagnarokConstants
import RagnarokCore
import RagnarokModels
import RagnarokPackets
import RagnarokRenderAssets
import RagnarokResources
import RagnarokSprite
import simd

private enum MapMovementDecision {
    case alreadyInRange
    case moveTo(SIMD2<Int>)
    case noPath
}

@MainActor
public final class MapScene {
    let mapName: String
    let world: WorldResource
    let character: CharacterInfo
    let player: MapObject
    let playerPosition: SIMD2<Int>
    let renderBackend: any GameRenderBackend
    let resourceManager: ResourceManager
    weak let gameSession: GameSession?

    let mapGrid: MapGrid
    let state: MapSceneState

    private let pathfinder: Pathfinder
    private var pendingArrivalAction: (@MainActor () -> Void)?
    private var arrivalTask: Task<Void, Never>?

    var cameraState: MapCameraState = .default {
        didSet {
            applySnapshot()
        }
    }

    init(
        mapName: String,
        world: WorldResource,
        character: CharacterInfo,
        player: MapObject,
        playerPosition: SIMD2<Int>,
        renderBackend: any GameRenderBackend,
        resourceManager: ResourceManager,
        gameSession: GameSession
    ) {
        self.mapName = mapName
        self.world = world
        self.character = character
        self.player = player
        self.playerPosition = playerPosition
        self.renderBackend = renderBackend
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
                headDirection: .lookForward,
                startTime: .now
            )
        )
        self.state = MapSceneState(player: playerState)

        self.pathfinder = Pathfinder(mapGrid: self.mapGrid)

        state.overlay.gauges[player.objectID] = MapGaugeOverlay(
            id: player.objectID,
            hp: character.hp,
            maxHp: character.maxHp,
            sp: character.sp,
            maxSp: character.maxSp,
            objectType: player.type
        )

        renderBackend.attach(scene: self)
    }

    func load(progress: Progress) async {
        await renderBackend.load(progress: progress)
        applySnapshot()
    }

    func unload() {
        arrivalTask?.cancel()
        arrivalTask = nil
        pendingArrivalAction = nil
        renderBackend.unload()
        renderBackend.detach()
    }

    func handleMovement(_ movementValue: CGPoint) {
        onMovementValueChanged(movementValue: movementValue)
    }

    func handleInteraction(_ result: GameHitTestResult) {
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
        state.selection = position
        applySnapshot()
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
            let dir = SpriteDirection(sourcePosition: path[i - 1], targetPosition: path[i])
            let stepMs = dir.isDiagonal ? Int((Double(speed) * sqrt(2)).rounded()) : speed
            total += .milliseconds(stepMs)
        }
        return total
    }

    private func playerMovementOrigin() -> SIMD2<Int> {
        if let path = state.player.movement?.path, path.count > 1 {
            return path[1]
        } else {
            return state.player.gridPosition
        }
    }

    private func applySnapshot() {
        state.pruneExpiredDamageEffects()
        renderBackend.applySnapshot(state)
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

    private func handleMapObjectSelection(objectID: GameObjectID) {
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

    private func decideMovement(from playerPosition: SIMD2<Int>, toward targetPosition: SIMD2<Int>, within range: Int) -> MapMovementDecision {
        let path = pathfinder.findPath(from: playerPosition, to: targetPosition, within: range)
        if path.isEmpty {
            return .noPath
        } else if path == [playerPosition] {
            return .alreadyInRange
        } else {
            return .moveTo(path.last ?? targetPosition)
        }
    }

    private func movePlayerToward(targetPosition: SIMD2<Int>, within range: Int, onArrival: @escaping @MainActor () -> Void) {
        let startPosition = state.player.gridPosition
        switch decideMovement(from: startPosition, toward: targetPosition, within: range) {
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

    private func gridPosition(for objectID: GameObjectID) -> SIMD2<Int>? {
        if state.player.id == objectID {
            state.player.gridPosition
        } else {
            state.objects[objectID]?.gridPosition
        }
    }

    private func mapObject(for objectID: GameObjectID) -> MapObject? {
        if state.player.id == objectID {
            state.player.object
        } else {
            state.objects[objectID]?.object
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
            state.overlay.gauges[player.objectID]?.hp = Int(packet.count)
            applySnapshot()
        case .maxhp:
            state.player.maxHp = Int(packet.count)
            state.overlay.gauges[player.objectID]?.maxHp = Int(packet.count)
            applySnapshot()
        case .sp:
            state.player.sp = Int(packet.count)
            state.overlay.gauges[player.objectID]?.sp = Int(packet.count)
            applySnapshot()
        case .maxsp:
            state.player.maxSp = Int(packet.count)
            state.overlay.gauges[player.objectID]?.maxSp = Int(packet.count)
            applySnapshot()
        default:
            break
        }
    }

    func onReceivePacket(_ packet: PACKET_ZC_HP_INFO) {
        if state.player.id == packet.GID {
            state.player.hp = Int(packet.HP)
            state.player.maxHp = Int(packet.maxHP)
            state.overlay.gauges[packet.GID]?.hp = Int(packet.HP)
            state.overlay.gauges[packet.GID]?.maxHp = Int(packet.maxHP)
        } else {
            state.objects[packet.GID]?.hp = Int(packet.HP)
            state.objects[packet.GID]?.maxHp = Int(packet.maxHP)
            state.overlay.gauges[packet.GID]?.hp = Int(packet.HP)
            state.overlay.gauges[packet.GID]?.maxHp = Int(packet.maxHP)
        }

        applySnapshot()
    }

    func onPlayerMoved(startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) {
        let now = ContinuousClock.now

        let animationElapsedOffset: Duration
        if let existingMovement = state.player.movement {
            animationElapsedOffset = existingMovement.animationElapsedOffset + existingMovement.startTime.duration(to: now)
        } else {
            animationElapsedOffset = .zero
        }

        let path = pathfinder.findPath(from: startPosition, to: endPosition)
        let direction = path.count >= 2
            ? SpriteDirection(sourcePosition: path[0], targetPosition: path[1])
            : SpriteDirection(sourcePosition: startPosition, targetPosition: endPosition)
        let duration = movementDuration(path: path, speed: state.player.object.speed)
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
        let direction = path.count >= 2
            ? SpriteDirection(sourcePosition: path[0], targetPosition: path[1])
            : SpriteDirection(sourcePosition: startPosition, targetPosition: endPosition)
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
        let sourceMapObject = mapObject(for: objectAction.sourceObjectID)

        let presentationAction: SpriteActionType
        let isAttackAction: Bool
        switch objectAction.type {
        case .sit_down:
            presentationAction = .sit
            isAttackAction = false
        case .stand_up:
            presentationAction = .idle
            isAttackAction = false
        case .pickup_item:
            presentationAction = .pickup
            isAttackAction = false
        case .normal, .endure, .critical, .multi_hit, .multi_hit_endure, .multi_hit_critical, .lucy_dodge:
            if let sourceMapObject {
                presentationAction = SpriteActionType.attackActionType(
                    forJobID: sourceMapObject.job,
                    gender: sourceMapObject.gender,
                    weapon: sourceMapObject.weapon
                )
            } else {
                presentationAction = .attack1
            }
            isAttackAction = true
        default:
            presentationAction = .attack1
            isAttackAction = false
        }

        let sourceDuration = Duration.milliseconds(objectAction.sourceSpeed)
        let sourceID = objectAction.sourceObjectID
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

        if isAttackAction,
           let sourceMapObject,
           SpriteJob(rawValue: sourceMapObject.job).isPlayer,
           let filename = WeaponSoundTable.attackSoundFilenames(
               for: WeaponType(rawValue: sourceMapObject.weapon) ?? .w_fist
           ).randomElement() {
            renderBackend.playSound(filename, on: objectAction.sourceObjectID)
        }

        if isAttackAction,
           objectAction.damage > 0,
           let targetMapObject = mapObject(for: objectAction.targetObjectID) {
            let hitFilename: String?
            let targetJob = SpriteJob(rawValue: targetMapObject.job)

            if targetJob.isPlayer {
                hitFilename = JobHitSoundTable.hitSoundFilenames(forJob: targetMapObject.job).randomElement()
            } else if let sourceMapObject, SpriteJob(rawValue: sourceMapObject.job).isPlayer {
                let weaponType = WeaponType(rawValue: sourceMapObject.weapon) ?? .w_fist
                let weaponHitFilename = WeaponHitSoundTable.hitSoundFilenames(for: weaponType).randomElement()
                hitFilename = weaponHitFilename ?? JobHitSoundTable.hitSoundFilenames(forJob: targetMapObject.job).randomElement()
            } else {
                hitFilename = JobHitSoundTable.hitSoundFilenames(forJob: targetMapObject.job).randomElement()
            }

            if let hitFilename {
                Task { @MainActor [weak self] in
                    try? await Task.sleep(for: .milliseconds(objectAction.sourceSpeed))
                    guard let self else { return }
                    renderBackend.playSound(hitFilename, on: objectAction.targetObjectID)
                }
            }
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
    }

    func onMapObjectSkillPerformed(_ packet: PACKET_ZC_NOTIFY_SKILL) {
        let now = ContinuousClock.now
        let sourceMapObject = if state.player.id == packet.AID {
            state.player.object
        } else {
            state.objects[packet.AID]?.object
        }

        if let sourceMapObject {
            let availableActionTypes = SpriteActionType.availableActionTypes(forJobID: sourceMapObject.job)
            let action: SpriteActionType = availableActionTypes.contains(.skill) ? .skill : .attack1
            let duration = Duration.milliseconds(Int(packet.attackMT))

            if state.player.id == packet.AID {
                state.player.presentation = MapObjectPresentationState(
                    action: action,
                    direction: state.player.presentation.direction,
                    headDirection: state.player.presentation.headDirection,
                    startTime: now,
                    duration: duration
                )
            } else if var objectState = state.objects[packet.AID] {
                objectState.presentation = MapObjectPresentationState(
                    action: action,
                    direction: objectState.presentation.direction,
                    headDirection: objectState.presentation.headDirection,
                    startTime: now,
                    duration: duration
                )
                state.objects[packet.AID] = objectState
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
