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
import RagnarokRenderAssets
import RagnarokRendering
import RagnarokResources
import RagnarokSprite
import simd

@MainActor
public final class MapScene {
    let mapName: String
    let mapGrid: MapGrid
    let pathFinder: PathFinder

    let resourceManager: ResourceManager
    let spriteLoader: SpriteLoader
    let audioPlayer: GameAudioPlayer
    weak var gameSession: GameSession?

    let state: MapSceneState

    var camera = MapSceneCamera()

    var fog = Fog()
    var sounds: [MapSceneSound] = []

    let player: MapSceneMapObject
    var objects: [GameObjectID: MapSceneMapObject] = [:]
    var items: [GameObjectID : MapSceneDroppedItem] = [:]
    var hpspBarObjectIDs: Set<GameObjectID> = []

    var effects: [UUID : MapSceneEffect] = [:]
    var combatTexts: [CombatText] = []
    var tileSelector: TileSelector?
    var targetSelector: TargetSelector?

    var selectedTargetID: GameObjectID?

    var selectedTarget: MapSceneMapObject? {
        if let selectedTargetID, let selectedTarget = objects[selectedTargetID], !selectedTarget.isDead {
            selectedTarget
        } else {
            nil
        }
    }

    private var pendingArrivalAction: (@MainActor () -> Void)?
    private var arrivalTask: Task<Void, any Error>?

    var thumbstickValue: CGPoint = .zero {
        didSet {
            updateThumbstickOctant()
        }
    }

    /// One of the 8 directions of the map grid that the thumbstick points to, or nil when the thumbstick is near the center.
    /// It changes only when the thumbstick turns 10 degrees past the boundary, so it does not flicker near the boundary.
    private(set) var thumbstickOctant: Int?

    private var thumbstickRequest: (target: SIMD2<Int>, octant: Int, time: ContinuousClock.Instant)?

    /// The cell where the player stops after the thumbstick is let go. It is kept until the server agrees.
    /// Until then, a late reply to an earlier request must not walk past this cell.
    private var thumbstickStopPosition: SIMD2<Int>?

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
        self.pathFinder = PathFinder(mapGrid: mapGrid)

        self.resourceManager = resourceManager
        self.spriteLoader = SpriteLoader(resourceManager: resourceManager)
        self.audioPlayer = audioPlayer
        self.gameSession = gameSession

        self.state = MapSceneState(
            playerPosition: playerPosition,
            playerDirection: .south
        )

        self.player = MapSceneMapObject(
            account: account,
            character: character,
            gridPosition: playerPosition,
            direction: .south,
            headDirection: .lookForward
        )
    }

    func load(world: WorldResource) async {
        let fogParameterTable = await resourceManager.fogParameterTable()
        if let parameter = fogParameterTable.fogParameter(forMapName: mapName) {
            fog = Fog(near: parameter.near, far: parameter.far, color: parameter.color.rgb)
        }

        sounds = world.rsw.sounds.map { sound in
            MapSceneSound(sound: sound, gnd: world.gnd)
        }

        objects[player.objectID] = player
        hpspBarObjectIDs.insert(player.objectID)

        await audioPlayer.playBGM(forMapName: mapName)
    }

    func unload() {
        spriteLoader.cancelAll()
        audioPlayer.stopBGM()
        audioPlayer.stopSoundEffects()

        camera.reset()
        sounds.removeAll()
        objects.removeAll()
        items.removeAll()
        hpspBarObjectIDs.removeAll()
        effects.removeAll()
        combatTexts.removeAll()
        tileSelector = nil
        selectTarget(nil)

        arrivalTask?.cancel()
        arrivalTask = nil
        pendingArrivalAction = nil
    }

    func jump(toPosition position: SIMD2<Int>) {
        camera.reset()
        objects.removeAll()
        items.removeAll()
        hpspBarObjectIDs.removeAll()
        effects.removeAll()
        combatTexts.removeAll()
        tileSelector = nil
        selectTarget(nil)

        player.movement = nil
        player.cast = nil
        player.gridPosition = position
        player.perform(.idle, completion: .indefinite)
        objects[player.objectID] = player
        hpspBarObjectIDs.insert(player.objectID)

        arrivalTask?.cancel()
        arrivalTask = nil
        pendingArrivalAction = nil
    }
}

// MARK: - Update

extension MapScene {
    func update(at time: ContinuousClock.Instant) {
        updateThumbstickMovement(at: time)

        let vanishedObjectIDs = objects.compactMap { objectID, object in
            object.death?.isVanished(at: time) == true ? objectID : nil
        }
        for objectID in vanishedObjectIDs {
            removeObject(objectID: objectID)
        }

        combatTexts.removeAll { combatText in
            combatText.isExpired(at: time)
        }

        for object in objects.values {
            object.update(at: time)
            if let movement = object.movement {
                object.gridPosition = movement.currentLocation.position
            }
        }

        camera.update(playerPosition: worldPosition(for: player), at: time)

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

        updateSounds(at: time)
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

        action.direction = action.direction.adjustedForCameraAzimuth(camera.azimuth)

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

        guard var soundName = composedSprite.mainFrameSound(
            forActionType: resolvedAction.actionType,
            direction: resolvedAction.direction,
            headDirection: resolvedAction.headDirection,
            frameIndex: resolvedAction.frameIndex
        ) else {
            return
        }

        if soundName == "atk" {
            guard let weaponSoundName = WeaponSoundTable.attackSoundNames(for: object.weaponType).first else {
                return
            }

            soundName = weaponSoundName
        }

        // An object can be heard however far away it is. Only the volume falls off.
        let source = GameAudio.Source(position: worldPosition(for: object), range: .infinity)
        audioPlayer.playSoundEffect(named: soundName, from: source)
    }

    private func updateSounds(at time: ContinuousClock.Instant) {
        let listenerPosition = worldPosition(for: player)
        audioPlayer.setListenerPosition(listenerPosition)

        for sound in sounds {
            if let nextPlayTime = sound.nextPlayTime, time < nextPlayTime {
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

            sound.nextPlayTime = time + sound.playInterval
        }
    }
}

// MARK: - Contents

extension MapScene {
    func resetCamera() {
        camera.azimuth = 0
        camera.elevation = .pi / 4
    }

    func addObject(objectID: GameObjectID, at gridPosition: SIMD2<Int>, direction: SpriteDirection, headDirection: SpriteHeadDirection) {
        guard let object = objects[objectID] else {
            return
        }
        object.gridPosition = gridPosition
        object.perform(.idle, completion: .indefinite)
        object.turn(direction: direction, headDirection: headDirection)
    }

    func removeObject(objectID: GameObjectID) {
        objects.removeValue(forKey: objectID)
        hpspBarObjectIDs.remove(objectID)
        if selectedTargetID == objectID {
            selectTarget(nil)
        }

        let ownedEffectObjectIDs = effects.compactMap { effectID, effect in
            effect.ownerObjectID == objectID ? effectID : nil
        }
        for effectObjectID in ownedEffectObjectIDs {
            removeEffect(objectID: effectObjectID)
        }
    }

    func moveObject(objectID: GameObjectID, startTime: ContinuousClock.Instant, startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) {
        guard let object = objects[objectID] else {
            return
        }

        let now = ContinuousClock.now
        let movement = object.replanMovement(
            startTime: startTime,
            startPosition: startPosition,
            endPosition: endPosition,
            speed: object.speed,
            pathFinder: pathFinder,
            at: now
        )

        object.gridPosition = movement.currentLocation.position
        let remainingDuration = movement.remainingDuration(at: now)
        object.perform(
            .walk,
            completion: .after(remainingDuration, nextActionType: .idle),
            at: now
        )
        if let finalDirection = movement.finalDirection {
            object.setDirection(finalDirection)
        }
    }

    func stopObject(objectID: GameObjectID, at position: SIMD2<Int>) {
        if let object = objects[objectID] {
            object.stopMovement(on: position)
            object.perform(.idle, completion: .indefinite)
        }
    }

    func cancelCast(for object: MapSceneMapObject) {
        if let spellEffectObjectID = object.cast?.spellEffectObjectID {
            removeEffect(objectID: spellEffectObjectID)
        }
        object.cast = nil
    }

    func removeEffect(objectID: UUID) {
        effects.removeValue(forKey: objectID)
    }
}

// MARK: - Interaction

extension MapScene {
    func handleInteraction(_ result: HitTestResult) {
        switch result {
        case .ground(let position):
            if player.action.actionType == .sit {
                player.look(at: position)
                gameSession?.changeDirection(
                    direction: Direction(spriteDirection: player.action.direction),
                    headDirection: HeadDirection(spriteHeadDirection: player.action.headDirection)
                )
            } else {
                if mapGrid.contains(position) {
                    tileSelector = TileSelector(position: position, showTime: .now)
                } else {
                    tileSelector = nil
                }
                requestMove(to: position)
            }
        case .mapObject(let objectID):
            if let target = objects[objectID], !target.isDead {
                switch target.type {
                case .monster, .npc:
                    selectTarget(target)
                    performActionOnSelectedTarget()
                default:
                    break
                }
            }
        case .mapItem(let objectID):
            if let item = items[objectID] {
                pickUpItem(item)
            }
        }
    }

    /// Selects the next monster or NPC, nearest first, and wraps around after the farthest one.
    /// Warps (job 45) and hidden NPCs (jobs 111 and 139) are skipped, since nothing is drawn for them.
    func selectNextTarget(where isInViewport: (MapSceneMapObject) -> Bool) {
        let candidates = objects.values
            .filter { object in
                guard !object.isDead, object.effectState != .cloak, object.effectState != .invisible else {
                    return false
                }

                guard isInViewport(object) else {
                    return false
                }

                switch object.type {
                case .monster:
                    return true
                case .npc:
                    return ![45, 111, 139].contains(object.job)
                default:
                    return false
                }
            }
            .sorted {
                let distance0 = distanceSquared($0.gridPosition, to: player.gridPosition)
                let distance1 = distanceSquared($1.gridPosition, to: player.gridPosition)
                return distance0 != distance1 ? distance0 < distance1 : $0.objectID < $1.objectID
            }
        guard !candidates.isEmpty else {
            return
        }

        let currentIndex = candidates.firstIndex { $0.objectID == selectedTargetID }
        let nextIndex = currentIndex.map { ($0 + 1) % candidates.count } ?? 0
        let target = candidates[nextIndex]

        selectTarget(target)
        targetSelector = TargetSelector(objectID: target.objectID, showTime: .now)
    }

    /// Attacks or talks to the selected target. Without one, it selects the nearest monster and attacks it.
    func performTargetAction() {
        if selectedTarget != nil {
            performActionOnSelectedTarget()
        } else if let target = nearestObject(ofType: .monster, fromPosition: player.gridPosition) {
            selectTarget(target)
            performActionOnSelectedTarget()
        }
    }

    func selectTarget(_ target: MapSceneMapObject?) {
        targetSelector = nil
        selectedTargetID = target?.objectID

        if state.selectedTargetObjectType != target?.type {
            state.selectedTargetObjectType = target?.type
        }
    }

    private func performActionOnSelectedTarget() {
        guard let selectedTarget else {
            return
        }

        targetSelector = nil

        switch selectedTarget.type {
        case .monster:
            attackMonster(targetID: selectedTarget.objectID)
        case .npc:
            gameSession?.talkToNPC(npcID: selectedTarget.objectID)
        default:
            break
        }
    }
}

// MARK: - Player Movement

extension MapScene {
    private enum MapMovementDecision {
        case alreadyInRange
        case moveTo(SIMD2<Int>)
        case noPath
    }

    func scheduleArrivalAction() {
        guard pendingArrivalAction != nil else {
            return
        }

        let remainingDuration = player.movement?.remainingDuration(at: .now) ?? .zero

        arrivalTask?.cancel()
        arrivalTask = Task { @MainActor [weak self] in
            try await Task.sleep(for: remainingDuration + .milliseconds(50))
            guard let self else {
                return
            }
            if let action = pendingArrivalAction {
                pendingArrivalAction = nil
                action()
            }
        }
    }

    func performArrivalAction() {
        guard let action = pendingArrivalAction else {
            return
        }

        arrivalTask?.cancel()
        arrivalTask = nil
        pendingArrivalAction = nil
        action()
    }

    private func requestMove(to position: SIMD2<Int>) {
        thumbstickStopPosition = nil
        gameSession?.requestMove(to: position)
    }

    private func movePlayerToward(targetPosition: SIMD2<Int>, within range: Int, onArrival: @escaping @MainActor () -> Void) {
        let startPosition = player.gridPosition
        switch decideMovement(from: startPosition, toward: targetPosition, within: range) {
        case .alreadyInRange:
            onArrival()
        case .moveTo(let destination):
            arrivalTask?.cancel()
            pendingArrivalAction = onArrival
            requestMove(to: destination)
        case .noPath:
            break
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

    func applyThumbstickStopPosition(toMovementEndingAt endPosition: SIMD2<Int>) {
        guard let thumbstickStopPosition else {
            return
        }

        if endPosition == thumbstickStopPosition {
            self.thumbstickStopPosition = nil
        } else {
            player.truncateMovement(to: thumbstickStopPosition)
        }
    }

    /// Walks in the thumbstick direction, like holding the mouse button in the official client.
    /// It keeps asking for a cell a few steps ahead. When the thumbstick is let go, it stops at the next cell.
    private func updateThumbstickMovement(at time: ContinuousClock.Instant) {
        updateThumbstickOctant()

        guard let octant = thumbstickOctant else {
            if thumbstickRequest != nil {
                thumbstickRequest = nil

                // Stop one cell after the next cell, so the server tells other players.
                // Stop now, because the server stops a little late.
                let upcomingPositions = player.movement?.upcomingPositions(at: time) ?? []
                if let stopPosition = upcomingPositions.dropFirst().first ?? upcomingPositions.first {
                    player.truncateMovement(to: stopPosition, at: time)
                    gameSession?.requestMove(to: stopPosition)
                    thumbstickStopPosition = stopPosition
                }
            }
            return
        }

        guard player.action.actionType != .sit else {
            return
        }

        if let thumbstickRequest {
            guard thumbstickRequest.time.duration(to: time) >= .milliseconds(200) else {
                return
            }

            // Ask again when the direction changes, or when the path is almost done.
            let isTurning = octant != thumbstickRequest.octant
            let remainingDuration = player.movement?.remainingDuration(at: time) ?? .zero
            let isRunningOut = remainingDuration < .milliseconds(player.speed * 3)
            guard isTurning || isRunningOut else {
                return
            }
        } else {
            arrivalTask?.cancel()
            arrivalTask = nil
            pendingArrivalAction = nil
            tileSelector = nil
        }

        // The server only changes its path when it gets to the next cell, so start looking from that cell.
        let origin = player.nextPosition(at: time) ?? player.gridPosition
        let target = thumbstickTarget(from: origin, toward: octant)
        if let target, target != thumbstickRequest?.target {
            requestMove(to: target)
        }
        thumbstickRequest = (target ?? origin, octant, time)
    }

    private func updateThumbstickOctant() {
        let thumbstickInput = SIMD2<Float>(Float(thumbstickValue.x), Float(-thumbstickValue.y))
        guard simd_length(thumbstickInput) > 15 else {
            thumbstickOctant = nil
            return
        }

        let azimuth = -camera.azimuth
        let worldInput = SIMD2<Float>(
            thumbstickInput.x * cos(azimuth) - thumbstickInput.y * sin(azimuth),
            thumbstickInput.x * sin(azimuth) + thumbstickInput.y * cos(azimuth)
        )
        let angle = atan2(worldInput.y, worldInput.x)

        if let thumbstickOctant {
            let angleFromOctant = remainder(angle - Float(thumbstickOctant) * .pi / 4, .pi * 2)
            guard abs(angleFromOctant) >= .pi / 8 + .pi / 18 else {
                return
            }
        }

        thumbstickOctant = (Int((angle / (.pi / 4)).rounded()) + 8) % 8
    }

    /// Finds the farthest cell, up to 6 cells away in one of the 8 directions,
    /// that the player can walk to in a straight line and that the server accepts.
    /// If the way is blocked, it tries the two directions next to it, so the player slides along walls.
    private func thumbstickTarget(from origin: SIMD2<Int>, toward octant: Int) -> SIMD2<Int>? {
        for octantOffset in [0, 1, -1] {
            let angle = Float(octant + octantOffset) * .pi / 4
            let step = SIMD2<Int>(Int(cos(angle).rounded()), Int(sin(angle).rounded()))
            for distance in stride(from: 6, through: 1, by: -1) {
                let target = origin &+ step &* distance
                if pathFinder.canMoveStraight(from: origin, to: target) && pathFinder.canRequestMove(from: origin, to: target) {
                    return target
                }
            }
        }
        return nil
    }
}

// MARK: - Player Actions

extension MapScene {
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
            requestMove(to: destination)
        case .noPath:
            break
        }
    }

    /// Uses a skill on the selected target. When the skill can't go to it,
    /// support and ground skills fall back to the player, and attack skills to the nearest monster.
    func useSkill(_ skill: SkillInfo, level: Int) {
        guard skill.level > 0, level > 0 else {
            return
        }

        let selectedTarget = selectedTarget

        if skill.isSelfOnlySkill {
            gameSession?.useSkill(skillID: skill.skillID, level: level, onTarget: player.objectID)
        } else if skill.isGroundTargetedSkill {
            if let selectedTarget {
                useSkill(skill, level: level, on: selectedTarget)
            } else {
                gameSession?.useSkill(skillID: skill.skillID, level: level, toGround: player.gridPosition)
            }
        } else if skill.isSupportSkill {
            if let selectedTarget, selectedTarget.type == .pc || selectedTarget.type == .monster {
                useSkill(skill, level: level, on: selectedTarget)
            } else {
                gameSession?.useSkill(skillID: skill.skillID, level: level, onTarget: player.objectID)
            }
        } else if let selectedTarget, selectedTarget.type == .monster {
            useSkill(skill, level: level, on: selectedTarget)
        } else if let target = nearestObject(ofType: .monster, fromPosition: player.gridPosition) {
            selectTarget(target)
            useSkill(skill, level: level, on: target)
        }
    }

    private func useSkill(_ skill: SkillInfo, level: Int, on target: MapSceneMapObject) {
        if targetSelector?.objectID == target.objectID {
            targetSelector = nil
        }

        let targetPosition = target.gridPosition
        let skillRange = max(skill.attackRange, 1)

        movePlayerToward(targetPosition: targetPosition, within: skillRange) {
            if skill.isGroundTargetedSkill {
                self.gameSession?.useSkill(
                    skillID: skill.skillID,
                    level: level,
                    toGround: targetPosition
                )
            } else {
                self.gameSession?.useSkill(
                    skillID: skill.skillID,
                    level: level,
                    onTarget: target.objectID
                )
            }
        }
    }

    func pickUpNearestItem() {
        if let target = nearestItem(fromPosition: player.gridPosition) {
            pickUpItem(target)
        }
    }

    private func pickUpItem(_ target: MapSceneDroppedItem) {
        movePlayerToward(targetPosition: target.gridPosition, within: 1) {
            self.gameSession?.pickUpItem(objectID: target.objectID)
        }
    }

    func toggleSit() {
        gameSession?.requestAction(player.action.actionType == .sit ? .stand_up : .sit_down)
    }
}

// MARK: - Queries

extension MapScene {
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

    func worldPosition(for object: MapSceneMapObject) -> SIMD3<Float> {
        if let movement = object.movement, movement.isMoving {
            mapGrid.worldPosition(at: movement.currentLocation.point)
        } else {
            mapGrid.worldPosition(for: object.gridPosition)
        }
    }

    func worldPosition(forObjectID objectID: GameObjectID) -> SIMD3<Float>? {
        objects[objectID].map(worldPosition(for:))
    }

    func isMonster(objectID: GameObjectID) -> Bool {
        switch objects[objectID]?.type {
        case .monster, .abr, .bionic:
            true
        default:
            false
        }
    }
}
