//
//  MapScene.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import CoreGraphics
import Foundation
import QuartzCore
import RagnarokConstants
import RagnarokCore
import RagnarokModels
import RagnarokPackets
import RagnarokRendering
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
    let mapGrid: MapGrid

    let player: MapSceneMapObject
    let resourceManager: ResourceManager
    let audioPlayer: GameAudioPlayer
    weak var gameSession: GameSession?

    let state: MapSceneState

    var objects: [GameObjectID: MapSceneMapObject] = [:]
    var items: [GameObjectID : MapSceneDroppedItem] = [:]
    let spriteLoader: SpriteLoader

    /// The objects that show health and spell point bars above them.
    var hpspBarObjectIDs: Set<GameObjectID> = []

    let pathFinder: PathFinder

    var combatTexts: [UUID : CombatText] = [:]

    var effects: [UUID : MapSceneEffect] = [:]

    var sounds: [MapSceneSound] = []

    var fog: Fog = .disabled
    var tileSelector: TileSelector?

    var pendingArrivalAction: (@MainActor () -> Void)?
    var arrivalTask: Task<Void, any Error>?

    var cameraState = MapCameraState()

    init(
        mapName: String,
        mapGrid: MapGrid,
        account: AccountInfo,
        character: CharacterInfo,
        playerPosition: SIMD2<Int>,
        resourceManager: ResourceManager,
        audioPlayer: GameAudioPlayer,
        gameSession: GameSession
    ) {
        self.mapName = mapName
        self.mapGrid = mapGrid
        self.resourceManager = resourceManager
        self.audioPlayer = audioPlayer
        self.gameSession = gameSession

        self.state = MapSceneState(
            playerPosition: playerPosition,
            playerDirection: .south
        )

        self.spriteLoader = SpriteLoader(resourceManager: resourceManager)

        self.pathFinder = PathFinder(mapGrid: self.mapGrid)

        self.player = MapSceneMapObject(
            account: account,
            character: character,
            gridPosition: playerPosition,
            direction: .south,
            headDirection: .lookForward
        )
        objects[player.objectID] = player

        hpspBarObjectIDs.insert(player.objectID)
    }

    func load() async {
        await audioPlayer.playBGM(forMapName: mapName)
    }

    func unload() {
        arrivalTask?.cancel()
        arrivalTask = nil
        pendingArrivalAction = nil
        audioPlayer.stopBGM()
        audioPlayer.stopSoundEffects()
        items.removeAll()
        spriteLoader.cancelAll()
        combatTexts.removeAll()
        effects.removeAll()
        sounds.removeAll()
        tileSelector = nil
    }

    func handleMovement(_ movementValue: CGPoint) {
        onMovementValueChanged(movementValue: movementValue)
    }

    func handleInteraction(_ result: HitTestResult) {
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
        tileSelector = mapGrid.contains(position)
            ? TileSelector(position: position, showTime: .now)
            : nil
        gameSession?.requestMove(to: position)
    }

    func resetCamera() {
        cameraState.azimuth = 0
        cameraState.elevation = .pi / 4
    }

    private func nearestObject(ofType type: MapObjectType, fromPosition position: SIMD2<Int>) -> MapSceneMapObject? {
        objects.values
            .filter {
                $0.type == type && !$0.isDead
            }
            .min {
                distanceSquared($0.gridPosition, to: position) < distanceSquared($1.gridPosition, to: position)
            }
    }

    private func nearestItem(fromPosition position: SIMD2<Int>) -> MapSceneDroppedItem? {
        items.values.min {
            distanceSquared($0.gridPosition, to: position) < distanceSquared($1.gridPosition, to: position)
        }
    }

    private func distanceSquared(_ a: SIMD2<Int>, to b: SIMD2<Int>) -> Int {
        let d = a &- b
        return d.x * d.x + d.y * d.y
    }

    private func onMovementValueChanged(movementValue: CGPoint) {
        let position = player.nextPosition(at: .now) ?? player.gridPosition

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
        if let target = nearestObject(ofType: .monster, fromPosition: player.gridPosition) {
            attackMonster(target)
        }
    }

    func useSkillOnNearestMonster(_ skill: SkillInfo) {
        guard skill.level > 0 else {
            return
        }

        if skill.isSelfOnlySkill || skill.isSupportSkill {
            gameSession?.useSkill(
                skillID: skill.skillID,
                level: skill.level,
                onTarget: player.objectID
            )
            return
        }

        if let target = nearestObject(ofType: .monster, fromPosition: player.gridPosition) {
            attackMonster(target, skill: skill)
        }
    }

    func pickUpNearestItem() {
        if let target = nearestItem(fromPosition: player.gridPosition) {
            pickUpItem(target)
        }
    }

    private func handleMapObjectSelection(objectID: GameObjectID) {
        guard let target = objects[objectID], !target.isDead else {
            return
        }

        switch target.type {
        case .monster:
            attackMonster(target)
        case .npc:
            gameSession?.talkToNPC(npcID: target.objectID)
        default:
            break
        }
    }

    private func attackMonster(_ target: MapSceneMapObject) {
        attackMonster(targetID: target.objectID)
    }

    private func attackMonster(targetID: GameObjectID) {
        guard let target = objects[targetID], !target.isDead else {
            return
        }

        let startPosition = player.gridPosition
        let attackRange = gameSession?.context.playerStatus.attackRange ?? 1
        switch decideMovement(from: startPosition, toward: target.gridPosition, within: attackRange) {
        case .alreadyInRange:
            gameSession?.requestAction(._repeat, onTarget: targetID)
        case .moveTo(let destination):
            arrivalTask?.cancel()
            pendingArrivalAction = { [weak self] in
                self?.attackMonster(targetID: targetID)
            }
            gameSession?.requestMove(to: destination)
        case .noPath:
            break
        }
    }

    private func attackMonster(_ target: MapSceneMapObject, skill: SkillInfo) {
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

    private func pickUpItem(_ target: MapSceneDroppedItem) {
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
        let startPosition = player.gridPosition
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

extension MapScene {
    func update(at now: ContinuousClock.Instant) {
        let vanishedObjectIDs = objects.compactMap { objectID, object in
            object.death?.isVanished(at: now) == true ? objectID : nil
        }
        for objectID in vanishedObjectIDs {
            removeObject(objectID: objectID)
        }

        let expiredCombatTextObjectIDs = combatTexts.compactMap { combatTextObjectID, combatText in
            combatText.isExpired(at: now) ? combatTextObjectID : nil
        }
        for combatTextObjectID in expiredCombatTextObjectIDs {
            combatTexts.removeValue(forKey: combatTextObjectID)
        }

        for object in objects.values {
            object.update(at: now)
            if let movement = object.movement {
                object.gridPosition = movement.currentPosition
            }
        }

        spriteLoader.load(objects: objects, items: items)

        for object in objects.values {
            let previousAction = object.resolvedAction
            object.resolvedAction = resolveAction(for: object)
            playActionSound(for: object, previousAction: previousAction)
        }

        let playerPosition = player.gridPosition
        if state.playerPosition != playerPosition {
            state.playerPosition = playerPosition
        }

        let playerDirection = player.movement?.direction ?? player.action.direction
        if state.playerDirection != playerDirection {
            state.playerDirection = playerDirection
        }

        updateSounds(at: now)
    }

    private func resolveAction(for object: MapSceneMapObject) -> ResolvedSpriteAction? {
        guard let composedSprite = object.composedSprite else {
            return nil
        }

        var action = object.action

        if let movement = object.movement, movement.isMoving {
            action.actionType = .walk
            action.direction = movement.direction ?? action.direction
            action.elapsedTime = movement.animationElapsedTime
            action.completion = .indefinite
        }

        action.direction = action.direction.adjustedForCameraAzimuth(cameraState.azimuth)

        if !SpriteActionType.availableActionTypes(forJobID: object.job).contains(action.actionType) {
            action.actionType = .idle
        }

        let frameIndex = composedSprite.mainFrameIndex(
            forActionType: action.actionType,
            direction: action.direction,
            headDirection: action.headDirection,
            elapsedTime: action.elapsedTime,
            attackDelay: object.attackDelay
        )

        return ResolvedSpriteAction(
            actionType: action.actionType,
            direction: action.direction,
            headDirection: action.headDirection,
            elapsedTime: action.elapsedTime,
            frameIndex: frameIndex ?? 0
        )
    }

    private func playActionSound(for object: MapSceneMapObject, previousAction: ResolvedSpriteAction?) {
        guard object.type != .pet,
              let composedSprite = object.composedSprite,
              let resolvedAction = object.resolvedAction else {
            return
        }

        if let previousAction,
           previousAction.actionType == resolvedAction.actionType,
           previousAction.frameIndex == resolvedAction.frameIndex {
            return
        }

        guard let soundName = composedSprite.mainFrameSound(
            forActionType: resolvedAction.actionType,
            direction: resolvedAction.direction,
            headDirection: resolvedAction.headDirection,
            frameIndex: resolvedAction.frameIndex
        ) else {
            return
        }

        // An object can be heard however far away it is. Only the volume falls off.
        let source = GameAudio.Source(position: worldPosition(for: object), range: .infinity)
        audioPlayer.playSoundEffect(named: soundName, from: source)
    }

    private func updateSounds(at now: ContinuousClock.Instant) {
        let listenerPosition = worldPosition(for: player)
        audioPlayer.setListenerPosition(listenerPosition)

        for sound in sounds {
            if let nextPlayTime = sound.nextPlayTime, now < nextPlayTime {
                continue
            }

            let source = GameAudio.Source(position: sound.position, range: sound.range)
            guard source.isInRange(ofListenerAtPosition: listenerPosition) else {
                continue
            }

            audioPlayer.playSoundEffect(
                named: sound.name,
                from: source
            )

            sound.nextPlayTime = now + sound.playInterval
        }
    }

    func worldPosition(for object: MapSceneMapObject) -> SIMD3<Float> {
        if let step = object.movement?.currentStep {
            mix(
                mapGrid.worldPosition(for: step.sourcePosition),
                mapGrid.worldPosition(for: step.targetPosition),
                t: step.fraction
            )
        } else {
            mapGrid.worldPosition(for: object.gridPosition)
        }
    }

    func worldPosition(forObjectID objectID: GameObjectID) -> SIMD3<Float>? {
        objects[objectID].map(worldPosition(for:))
    }
}
