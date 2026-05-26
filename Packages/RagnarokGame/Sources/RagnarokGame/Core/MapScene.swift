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

    let pathFinder: PathFinder

    var pendingArrivalAction: (@MainActor () -> Void)?
    var arrivalTask: Task<Void, any Error>?

    var cameraState: MapCameraState = .default {
        didSet {
            renderBackend.updateCamera(cameraState)
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

        let playerObject = MapSceneObject(
            object: player,
            gridPosition: playerPosition,
            hp: character.hp,
            maxHp: character.maxHp,
            sp: character.sp,
            maxSp: character.maxSp
        )
        self.state = MapSceneState(player: playerObject)

        self.pathFinder = PathFinder(mapGrid: self.mapGrid)

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
        renderBackend.addObject(state.player, direction: .south, headDirection: .lookForward)
        renderBackend.updateCamera(cameraState)
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
        case .mapItem(let objectID):
            gameSession?.pickUpItem(objectID: objectID)
        }
    }

    func selectGround(at position: SIMD2<Int>) {
        renderBackend.showSelection(at: position, mapGrid: mapGrid)
        gameSession?.requestMove(to: position)
    }

    func resetCamera() {
        cameraState.azimuth = 0
        cameraState.elevation = .pi / 4
    }

    private func playerMovementOrigin() -> SIMD2<Int> {
        renderBackend.presentationGridPosition(for: player.objectID) ?? state.player.gridPosition
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
            gameSession?.talkToNPC(npcID: target.objectID)
        }
    }

    private func handleMapObjectSelection(objectID: GameObjectID) {
        guard let target = state.objects[objectID] else {
            return
        }

        switch target.type {
        case .monster:
            engageMonster(target)
        case .npc:
            gameSession?.talkToNPC(npcID: target.objectID)
        default:
            break
        }
    }

    private func engageMonster(_ target: MapSceneObject) {
        movePlayerToward(targetPosition: target.gridPosition, within: 1) {
            self.gameSession?.requestAction(._repeat, onTarget: target.objectID)
        }
    }

    private func engageMonster(_ target: MapSceneObject, skill: SkillInfo) {
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
                    onTarget: target.objectID
                )
            }
        }
    }

    private func engageItem(_ target: MapSceneItem) {
        movePlayerToward(targetPosition: target.gridPosition, within: 1) {
            self.gameSession?.pickUpItem(objectID: target.objectID)
        }
    }

    private func decideMovement(from playerPosition: SIMD2<Int>, toward targetPosition: SIMD2<Int>, within range: Int) -> MapMovementDecision {
        let path = pathFinder.findPath(from: playerPosition, to: targetPosition, within: range)
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
}
