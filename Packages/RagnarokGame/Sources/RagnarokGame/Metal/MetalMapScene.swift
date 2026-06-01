//
//  MetalMapScene.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
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

public final class MetalMapScene: GameMapScene {
    public let mapName: String

    let world: WorldResource
    let character: CharacterInfo
    let player: MapObject
    let playerPosition: SIMD2<Int>
    let renderBackend: MetalRenderBackend
    let resourceManager: ResourceManager
    weak var gameSession: GameSession?

    let mapGrid: MapGrid
    let state: MetalSceneState

    let objectRegistry = MetalMapObjectRegistry()
    let itemRegistry = MetalMapItemRegistry()

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
        resourceManager: ResourceManager,
        gameSession: GameSession
    ) throws {
        self.mapName = mapName
        self.world = world
        self.character = character
        self.player = player
        self.playerPosition = playerPosition
        self.renderBackend = try MetalRenderBackend(resourceManager: resourceManager)
        self.resourceManager = resourceManager
        self.gameSession = gameSession

        self.mapGrid = MapGrid(gat: world.gat)
        self.state = MetalSceneState()

        self.pathFinder = PathFinder(mapGrid: self.mapGrid)

        let metalPlayer = MetalPlayerObject(
            object: player,
            hp: character.hp,
            maxHp: character.maxHp,
            sp: character.sp,
            maxSp: character.maxSp,
            gridPosition: playerPosition,
            mapGrid: mapGrid,
            pathFinder: pathFinder
        )
        objectRegistry.add(metalPlayer)

        state.overlay.gauges[player.objectID] = MetalGaugeOverlay(
            id: player.objectID,
            hp: character.hp,
            maxHp: character.maxHp,
            sp: character.sp,
            maxSp: character.maxSp,
            objectType: player.type
        )

        renderBackend.attach(scene: self)
    }

    public func load(progress: Progress) async {
        await renderBackend.load(progress: progress)
        renderBackend.addObject(objectID: player.objectID, at: playerPosition, direction: .south, headDirection: .lookForward)
        renderBackend.updateCamera(cameraState)
    }

    public func unload() {
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

    private func nearestObject(ofType type: MapObjectType, fromPosition position: SIMD2<Int>) -> MetalMapObject? {
        objectRegistry.nearestObject(ofType: type, fromPosition: position)
    }

    private func nearestItem(fromPosition position: SIMD2<Int>) -> MetalMapItem? {
        itemRegistry.nearestItem(fromPosition: position)
    }

    private func onMovementValueChanged(movementValue: CGPoint) {
        guard let playerObject = objectRegistry.object(for: player.objectID) else {
            return
        }
        let position = playerObject.movementController.nextPosition(at: .now) ?? playerObject.gridPosition

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
        if let playerPosition = objectRegistry.object(for: player.objectID)?.gridPosition,
           let target = nearestObject(ofType: .monster, fromPosition: playerPosition) {
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

        if let playerPosition = objectRegistry.object(for: player.objectID)?.gridPosition,
           let target = nearestObject(ofType: .monster, fromPosition: playerPosition) {
            engageMonster(target, skill: skill)
        }
    }

    func pickUpNearestItem() {
        if let playerPosition = objectRegistry.object(for: player.objectID)?.gridPosition,
           let target = nearestItem(fromPosition: playerPosition) {
            engageItem(target)
        }
    }

    func talkToNearestNPC() {
        if let playerPosition = objectRegistry.object(for: player.objectID)?.gridPosition,
           let target = nearestObject(ofType: .npc, fromPosition: playerPosition) {
            gameSession?.talkToNPC(npcID: target.objectID)
        }
    }

    private func handleMapObjectSelection(objectID: GameObjectID) {
        guard let target = objectRegistry.object(for: objectID) else {
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

    private func engageMonster(_ target: MetalMapObject) {
        let targetPosition = target.gridPosition
        movePlayerToward(targetPosition: targetPosition, within: 1) {
            self.gameSession?.requestAction(._repeat, onTarget: target.objectID)
        }
    }

    private func engageMonster(_ target: MetalMapObject, skill: SkillInfo) {
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

    private func engageItem(_ target: MetalMapItem) {
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
        let startPosition = objectRegistry.object(for: player.objectID)?.gridPosition ?? playerPosition
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
