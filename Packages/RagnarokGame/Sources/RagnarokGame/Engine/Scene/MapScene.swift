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
    let realityKitBackend: RealityKitMapBackend

    private let pathfinder: Pathfinder
    private let interactionResolver: MapInteractionResolver

    var cameraState: MapCameraState = .default {
        didSet {
            realityKitBackend.updateCameraState(cameraState)
        }
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
            isVisible: player.effectState != .cloak
        )
        self.state = MapSceneState(player: playerState)

        self.pathfinder = Pathfinder(mapGrid: self.mapGrid)
        self.interactionResolver = MapInteractionResolver(pathfinder: self.pathfinder)
        self.realityKitBackend = RealityKitMapBackend(resourceManager: resourceManager)

        state.overlaySnapshot.anchors[player.objectID] = MapOverlayAnchor(
            id: player.objectID,
            hp: character.hp,
            maxHp: character.maxHp,
            sp: character.sp,
            maxSp: character.maxSp,
            objectType: player.type
        )

        realityKitBackend.attach(scene: self)
    }

    func load(progress: Progress) async {
        await realityKitBackend.load(progress: progress)
        realityKitBackend.applySnapshot(state)
    }

    func unload() {
        realityKitBackend.unload()
        realityKitBackend.detach()
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
        realityKitBackend.applySnapshot(state)
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

    private func onMovementValueChanged(movementValue: CGPoint) {
        let position = realityKitBackend.currentPlayerMovementOrigin() ?? state.player.gridPosition

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
            realityKitBackend.schedulePlayerArrivalAction(within: range, onArrival: onArrival)
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
                await realityKitBackend.updateHealthAndSpellPoints(
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
                await realityKitBackend.updateHealthAndSpellPoints(
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
                await realityKitBackend.updateHealthAndSpellPoints(
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
                await realityKitBackend.updateHealthAndSpellPoints(
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
            await realityKitBackend.updateHealthAndSpellPoints(
                for: packet.GID,
                hp: Int(packet.HP),
                maxHp: Int(packet.maxHP),
                sp: nil,
                maxSp: nil
            )
        }
    }

    func onPlayerMoved(startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) {
        state.player.gridPosition = endPosition
        Task {
            await realityKitBackend.movePlayer(from: startPosition, to: endPosition, cameraState: cameraState)
        }
    }

    func onMapObjectSpawned(object: MapObject, position: SIMD2<Int>, direction: Direction, headDirection: HeadDirection) {
        state.objects[object.objectID] = MapObjectState(
            id: object.objectID,
            object: object,
            gridPosition: position,
            hp: object.hp,
            maxHp: object.maxHp,
            isVisible: object.effectState != .cloak
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
            await realityKitBackend.spawnMapObject(
                object,
                position: position,
                direction: direction
            )
        }
    }

    func onMapObjectMoved(object: MapObject, startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) {
        if state.objects[object.objectID] != nil {
            state.objects[object.objectID]?.gridPosition = endPosition
        } else {
            state.objects[object.objectID] = MapObjectState(
                id: object.objectID,
                object: object,
                gridPosition: endPosition,
                hp: object.hp,
                maxHp: object.maxHp,
                isVisible: object.effectState != .cloak
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
            await realityKitBackend.moveMapObject(
                object,
                startPosition: startPosition,
                endPosition: endPosition
            )
        }
    }

    func onMapObjectStopped(objectID: UInt32, position: SIMD2<Int>) {
        state.objects[objectID]?.gridPosition = position

        Task {
            await realityKitBackend.stopMapObject(objectID: objectID, position: position)
        }
    }

    func onMapObjectVanished(objectID: UInt32) {
        state.objects.removeValue(forKey: objectID)
        state.overlaySnapshot.anchors.removeValue(forKey: objectID)

        Task {
            await realityKitBackend.removeMapObject(objectID: objectID)
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
            await realityKitBackend.setVisibility(forObjectID: objectID, isVisible: isVisible)
        }
    }

    func onMapObjectActionPerformed(objectAction: MapObjectAction) {
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
            await realityKitBackend.performMapObjectAction(objectAction)
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
            await realityKitBackend.performSkill(packet)
        }
    }

    func onItemSpawned(item: MapItem, position: SIMD2<Int>) {
        state.items[item.objectID] = MapItemState(
            id: item.objectID,
            item: item,
            gridPosition: position
        )

        Task {
            await realityKitBackend.spawnItem(item, position: position)
        }
    }

    func onItemVanished(objectID: UInt32) {
        state.items.removeValue(forKey: objectID)

        Task {
            await realityKitBackend.removeItem(objectID: objectID)
        }
    }
}
