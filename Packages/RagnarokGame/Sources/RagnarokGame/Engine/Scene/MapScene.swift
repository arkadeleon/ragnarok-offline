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
import RagnarokEffects
import RagnarokModels
import RagnarokPackets
import RagnarokRenderAssets
import RagnarokRendering
import RagnarokResources
import RagnarokSprite
import simd

@MainActor
protocol MapSceneObserver: AnyObject {
    func mapSceneDidAddObject(_ object: MapSceneMapObject)
    func mapSceneDidUpdateObjectSprite(_ object: MapSceneMapObject)
    func mapSceneDidRemoveObject(objectID: GameObjectID)
    func mapSceneDidAddItem(_ item: MapSceneDroppedItem)
    func mapSceneDidRemoveItem(objectID: GameObjectID)
    func mapSceneDidAddEffect(_ effect: MapSceneEffect)
    func mapSceneDidRemoveEffect(instanceID: UUID)
    func mapSceneDidClear()
}

@MainActor
public final class MapScene {
    let mapName: String
    let world: MapWorld

    let resourceManager: ResourceManager
    let spriteLoader: SpriteLoader
    let audioPlayer: GameAudioPlayer
    let playSession: PlaySession

    weak var observer: (any MapSceneObserver)?

    let state: MapSceneState

    var camera = MapSceneCamera()
    var lastCameraWorldPosition: SIMD3<Float>?

    var tileSelector: TileSelector?
    var targetSelector: TargetSelector?

    var selectedTargetID: GameObjectID?

    var selectedTarget: MapSceneMapObject? {
        if let selectedTargetID, let selectedTarget = world.objects[selectedTargetID], !selectedTarget.isDead {
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

    private var thumbstickRequest: (target: SIMD2<Int>, octant: Int, time: TimeInterval)?

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
        playSession: PlaySession
    ) {
        self.mapName = mapName
        self.world = MapWorld(
            mapGrid: mapGrid,
            account: account,
            character: character,
            playerPosition: playerPosition
        )

        self.resourceManager = resourceManager
        self.spriteLoader = SpriteLoader(resourceManager: resourceManager)
        self.audioPlayer = audioPlayer
        self.playSession = playSession

        self.state = MapSceneState(
            playerPosition: playerPosition,
            playerDirection: .south
        )
    }

    func load(world worldResource: WorldResource) async {
        let fogParameterTable = await resourceManager.fogParameterTable()
        if let parameter = fogParameterTable.fogParameter(forMapName: mapName) {
            world.fog = Fog(near: parameter.near, far: parameter.far, color: parameter.color.rgb)
        }

        world.sounds = worldResource.rsw.sounds.map { sound in
            MapSceneSound(sound: sound, gnd: worldResource.gnd)
        }

        world.player.showsHPSPBar = true
        registerObject(world.player)

        await audioPlayer.playBGM(forMapName: mapName)
    }

    func unload() {
        spriteLoader.cancelAll()

        audioPlayer.stopBGM()
        audioPlayer.stopSoundEffects()

        camera.reset()

        world.clear(includingSounds: true)

        tileSelector = nil
        selectTarget(nil)

        observer?.mapSceneDidClear()

        cancelArrivalAction()
    }

    func jump(toPosition position: SIMD2<Int>) {
        spriteLoader.cancelAll()

        camera.reset()

        world.clear(includingSounds: false)

        tileSelector = nil
        selectTarget(nil)

        observer?.mapSceneDidClear()

        world.player.movement = nil
        world.player.cast = nil
        world.player.gridPosition = position
        world.player.worldPosition = world.mapGrid.worldPosition(for: position)
        world.player.showsHPSPBar = true
        world.player.perform(.idle, completion: .indefinite)
        registerObject(world.player)

        cancelArrivalAction()
    }
}

// MARK: - Update

extension MapScene {
    func update(atTime worldTime: MapWorldTime) {
        let currentTime = worldTime.time

        updateThumbstickMovement(atTime: currentTime)

        for objectID in world.vanishedObjectIDs(atTime: currentTime) {
            removeObject(objectID: objectID)
        }

        world.removeExpiredCombatTexts(atTime: currentTime)
        world.updateObjects(atTime: currentTime)

        camera.update(playerPosition: world.player.worldPosition, atTime: currentTime)

        for object in world.objects.values {
            let previousAction = object.resolvedAction
            object.resolvedAction = object.resolveAction(cameraAzimuth: camera.azimuth)
            playActionSound(for: object, previousAction: previousAction)
        }

        let playerPosition = world.player.gridPosition
        if state.playerPosition != playerPosition {
            state.playerPosition = playerPosition
        }

        let playerDirection = world.player.movement?.direction ?? world.player.action.direction
        if state.playerDirection != playerDirection {
            state.playerDirection = playerDirection
        }

        updateSounds(atTime: currentTime)
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
        let source = GameAudio.Source(position: object.worldPosition, range: .infinity)
        audioPlayer.playSoundEffect(named: soundName, from: source)
    }

    private func updateSounds(atTime currentTime: TimeInterval) {
        let listenerPosition = world.player.worldPosition
        audioPlayer.setListenerPosition(listenerPosition)

        for sound in world.sounds {
            if let nextPlayTime = sound.nextPlayTime, currentTime < nextPlayTime {
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

            sound.nextPlayTime = currentTime + sound.playInterval
        }
    }
}

// MARK: - Contents

extension MapScene {
    func resetCamera() {
        camera.animate(azimuth: 0, elevation: .pi / 4)
    }

    func registerObject(_ object: MapSceneMapObject) {
        world.objects[object.objectID] = object
        spriteLoader.loadSprite(forObject: object)

        observer?.mapSceneDidAddObject(object)
    }

    func notifyObjectSpriteChanged(_ object: MapSceneMapObject) {
        spriteLoader.loadSprite(forObject: object)

        observer?.mapSceneDidUpdateObjectSprite(object)
    }

    func addObject(objectID: GameObjectID, at gridPosition: SIMD2<Int>, direction: SpriteDirection, headDirection: SpriteHeadDirection) {
        guard let object = world.objects[objectID] else {
            return
        }
        object.gridPosition = gridPosition
        object.worldPosition = world.mapGrid.worldPosition(for: gridPosition)
        object.perform(.idle, completion: .indefinite)
        object.turn(direction: direction, headDirection: headDirection)
    }

    func removeObject(objectID: GameObjectID) {
        world.objects.removeValue(forKey: objectID)
        spriteLoader.cancelObjectLoad(forObjectID: objectID)

        observer?.mapSceneDidRemoveObject(objectID: objectID)

        if selectedTargetID == objectID {
            selectTarget(nil)
        }

        removeEffects(ownedBy: objectID)
    }

    func moveObject(objectID: GameObjectID, startTime: TimeInterval, startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) {
        guard let object = world.objects[objectID] else {
            return
        }

        let currentTime = CACurrentMediaTime()
        let movement = object.replanMovement(
            startTime: startTime,
            startPosition: startPosition,
            endPosition: endPosition,
            speed: object.speed,
            pathFinder: world.pathFinder,
            atTime: currentTime
        )

        object.gridPosition = movement.currentLocation.position
        object.worldPosition = movement.isMoving
            ? world.mapGrid.worldPosition(at: movement.currentLocation.point)
            : world.mapGrid.worldPosition(for: object.gridPosition)
        let remainingDuration = movement.remainingDuration(atTime: currentTime)
        object.perform(
            .walk,
            completion: .after(remainingDuration, nextActionType: .idle),
            atTime: currentTime
        )
        if let finalDirection = movement.finalDirection {
            object.setDirection(finalDirection)
        }
    }

    func stopObject(objectID: GameObjectID, at position: SIMD2<Int>) {
        if let object = world.objects[objectID] {
            object.stopMovement(on: position)
            object.worldPosition = world.mapGrid.worldPosition(for: position)
            object.perform(.idle, completion: .indefinite)
        }
    }

    func cancelCast(for object: MapSceneMapObject) {
        removeEffects(ownedBy: object.objectID, key: .cast)
        object.cast = nil
    }

    func addItem(_ item: MapSceneDroppedItem) {
        world.items[item.objectID] = item
        spriteLoader.loadSprite(forItem: item)

        observer?.mapSceneDidAddItem(item)
    }

    func removeItem(objectID: GameObjectID) {
        world.items.removeValue(forKey: objectID)
        spriteLoader.cancelItemLoad(forItemID: objectID)

        observer?.mapSceneDidRemoveItem(objectID: objectID)
    }

    func addEffect(_ effect: MapSceneEffect) {
        world.addEffect(effect)

        observer?.mapSceneDidAddEffect(effect)
    }

    func removeEffect(instanceID: UUID) {
        guard world.removeEffect(instanceID: instanceID) != nil else {
            return
        }

        observer?.mapSceneDidRemoveEffect(instanceID: instanceID)
    }

    func removeEffects(ownedBy ownerObjectID: GameObjectID, key: EffectAttachmentKey? = nil) {
        for instanceID in world.removeEffects(ownedBy: ownerObjectID, key: key) {
            observer?.mapSceneDidRemoveEffect(instanceID: instanceID)
        }
    }
}

// MARK: - Interaction

extension MapScene {
    func handleInteraction(_ result: HitTestResult) {
        switch result {
        case .ground(let position):
            if world.player.action.actionType == .sit {
                world.player.look(at: position)
                playSession.changeDirection(
                    direction: Direction(spriteDirection: world.player.action.direction),
                    headDirection: HeadDirection(spriteHeadDirection: world.player.action.headDirection)
                )
            } else {
                if world.mapGrid.contains(position) {
                    tileSelector = TileSelector(position: position, showTime: CACurrentMediaTime())
                } else {
                    tileSelector = nil
                }
                cancelArrivalAction()
                requestMove(to: position)
            }
        case .mapObject(let objectID):
            guard objectID != world.player.objectID, let target = world.objects[objectID], !target.isDead else {
                return
            }

            switch target.type {
            case .pc:
                selectTarget(target)
                targetSelector = TargetSelector(objectID: target.objectID, showTime: CACurrentMediaTime())
            case .monster, .npc:
                if playSession.interactionMode != .select || selectedTargetID == objectID {
                    selectTarget(target)
                    performActionOnSelectedTarget()
                } else {
                    selectTarget(target)
                    targetSelector = TargetSelector(objectID: target.objectID, showTime: CACurrentMediaTime())
                }
            default:
                break
            }
        case .mapItem(let objectID):
            if let item = world.items[objectID] {
                pickUpItem(item)
            }
        }
    }

    /// Selects the next monster or NPC, nearest first, and wraps around after the farthest one.
    /// Warps (job 45) and hidden NPCs (jobs 111 and 139) are skipped, since nothing is drawn for them.
    func selectNextTarget(where isInViewport: (MapSceneMapObject) -> Bool) {
        let candidates = world.objects.values
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
                let distance0 = distanceSquared($0.gridPosition, to: world.player.gridPosition)
                let distance1 = distanceSquared($1.gridPosition, to: world.player.gridPosition)
                return distance0 != distance1 ? distance0 < distance1 : $0.objectID < $1.objectID
            }
        guard !candidates.isEmpty else {
            return
        }

        let currentIndex = candidates.firstIndex { $0.objectID == selectedTargetID }
        let nextIndex = currentIndex.map { ($0 + 1) % candidates.count } ?? 0
        let target = candidates[nextIndex]

        selectTarget(target)
        targetSelector = TargetSelector(objectID: target.objectID, showTime: CACurrentMediaTime())
    }

    /// Attacks or talks to the selected target. Without one, it selects the nearest monster and attacks it.
    func performTargetAction() {
        if selectedTarget != nil {
            performActionOnSelectedTarget()
        } else if let target = nearestObject(ofType: .monster, fromPosition: world.player.gridPosition) {
            selectTarget(target)
            performActionOnSelectedTarget()
        }
    }

    func selectTarget(_ target: MapSceneMapObject?) {
        targetSelector = nil
        selectedTargetID = target?.objectID

        if state.selectedTargetType != target?.type {
            state.selectedTargetType = target?.type
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
            playSession.talkToNPC(npcID: selectedTarget.objectID)
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

        let remainingDuration = world.player.movement?.remainingDuration(atTime: CACurrentMediaTime()) ?? 0

        arrivalTask?.cancel()
        arrivalTask = Task { @MainActor [weak self] in
            try await Task.sleep(for: .seconds(remainingDuration + 0.05))
            guard let self else {
                return
            }
            if let action = pendingArrivalAction.take() {
                action()
            }
        }
    }

    func performArrivalAction() {
        guard let action = pendingArrivalAction.take() else {
            return
        }

        arrivalTask?.cancel()
        arrivalTask = nil

        action()
    }

    private func cancelArrivalAction() {
        arrivalTask?.cancel()
        arrivalTask = nil

        pendingArrivalAction = nil
    }

    private func requestMove(to position: SIMD2<Int>) {
        thumbstickStopPosition = nil
        playSession.requestMove(to: position)
    }

    private func movePlayerToward(targetPosition: SIMD2<Int>, within range: Int, onArrival: @escaping @MainActor () -> Void) {
        let startPosition = world.player.gridPosition
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
        let path = world.pathFinder.findPath(from: playerPosition, to: targetPosition, within: range)
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
            world.player.truncateMovement(to: thumbstickStopPosition)
        }
    }

    /// Walks in the thumbstick direction, like holding the mouse button in the official client.
    /// It keeps asking for a cell a few steps ahead. When the thumbstick is let go, it stops at the next cell.
    private func updateThumbstickMovement(atTime currentTime: TimeInterval) {
        updateThumbstickOctant()

        guard let octant = thumbstickOctant else {
            if thumbstickRequest != nil {
                thumbstickRequest = nil

                // Stop one cell after the next cell, so the server tells other players.
                // Stop now, because the server stops a little late.
                let upcomingPositions = world.player.movement?.upcomingPositions(atTime: currentTime) ?? []
                if let stopPosition = upcomingPositions.dropFirst().first ?? upcomingPositions.first {
                    world.player.truncateMovement(to: stopPosition, atTime: currentTime)
                    playSession.requestMove(to: stopPosition)
                    thumbstickStopPosition = stopPosition
                }
            }
            return
        }

        guard world.player.action.actionType != .sit else {
            return
        }

        if let thumbstickRequest {
            guard currentTime - thumbstickRequest.time >= 0.2 else {
                return
            }

            // Ask again when the direction changes, or when the path is almost done.
            let isTurning = octant != thumbstickRequest.octant
            let remainingDuration = world.player.movement?.remainingDuration(atTime: currentTime) ?? 0
            let isRunningOut = remainingDuration < TimeInterval(world.player.speed * 3) / 1000
            guard isTurning || isRunningOut else {
                return
            }
        } else {
            cancelArrivalAction()
            tileSelector = nil
        }

        // The server only changes its path when it gets to the next cell, so start looking from that cell.
        let origin = world.player.nextPosition(atTime: currentTime) ?? world.player.gridPosition
        let target = thumbstickTarget(from: origin, toward: octant)
        if let target, target != thumbstickRequest?.target {
            requestMove(to: target)
        }
        thumbstickRequest = (target ?? origin, octant, currentTime)
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
                if world.pathFinder.canMoveStraight(from: origin, to: target) && world.pathFinder.canRequestMove(from: origin, to: target) {
                    return target
                }
            }
        }
        return nil
    }
}

// MARK: - Player Actions

extension MapScene {
    func attackMonster(targetID: GameObjectID) {
        guard let target = world.objects[targetID], !target.isDead else {
            return
        }

        let startPosition = world.player.gridPosition
        let attackRange = playSession.playerStatus.attackRange

        switch decideMovement(from: startPosition, toward: target.gridPosition, within: attackRange) {
        case .alreadyInRange:
            playSession.requestAction(._repeat, onTarget: targetID)
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
            playSession.useSkill(skillID: skill.skillID, level: level, onTarget: world.player.objectID)
        } else if skill.isGroundTargetedSkill {
            if let selectedTarget {
                useSkill(skill, level: level, on: selectedTarget)
            } else {
                playSession.useSkill(skillID: skill.skillID, level: level, toGround: world.player.gridPosition)
            }
        } else if skill.isSupportSkill {
            if let selectedTarget, selectedTarget.type == .pc || selectedTarget.type == .monster {
                useSkill(skill, level: level, on: selectedTarget)
            } else {
                playSession.useSkill(skillID: skill.skillID, level: level, onTarget: world.player.objectID)
            }
        } else if let selectedTarget, selectedTarget.type == .monster {
            useSkill(skill, level: level, on: selectedTarget)
        } else if let target = nearestObject(ofType: .monster, fromPosition: world.player.gridPosition) {
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
                self.playSession.useSkill(
                    skillID: skill.skillID,
                    level: level,
                    toGround: targetPosition
                )
            } else {
                self.playSession.useSkill(
                    skillID: skill.skillID,
                    level: level,
                    onTarget: target.objectID
                )
            }
        }
    }

    func pickUpNearestItem() {
        if let target = nearestItem(fromPosition: world.player.gridPosition) {
            pickUpItem(target)
        }
    }

    private func pickUpItem(_ target: MapSceneDroppedItem) {
        movePlayerToward(targetPosition: target.gridPosition, within: 1) {
            self.playSession.pickUpItem(objectID: target.objectID)
        }
    }

    func toggleSit() {
        cancelArrivalAction()
        playSession.requestAction(world.player.action.actionType == .sit ? .stand_up : .sit_down)
    }
}

// MARK: - Queries

extension MapScene {
    private func nearestObject(ofType type: MapObjectType, fromPosition position: SIMD2<Int>) -> MapSceneMapObject? {
        world.objects.values
            .filter {
                $0.type == type && !$0.isDead
            }
            .min {
                distanceSquared($0.gridPosition, to: position) < distanceSquared($1.gridPosition, to: position)
            }
    }

    private func nearestItem(fromPosition position: SIMD2<Int>) -> MapSceneDroppedItem? {
        world.items.values.min {
            distanceSquared($0.gridPosition, to: position) < distanceSquared($1.gridPosition, to: position)
        }
    }

    private func distanceSquared(_ a: SIMD2<Int>, to b: SIMD2<Int>) -> Int {
        let d = a &- b
        return d.x * d.x + d.y * d.y
    }

    func isMonster(objectID: GameObjectID) -> Bool {
        switch world.objects[objectID]?.type {
        case .monster, .abr, .bionic:
            true
        default:
            false
        }
    }
}

// MARK: - EffectWorldContext

extension MapScene: EffectWorldContext {
    public var cameraWorldPosition: SIMD3<Float> {
        lastCameraWorldPosition ?? world.player.worldPosition
    }

    public var cameraYawDegrees: Float {
        degrees(camera.azimuth)
    }

    public func terrainHeight(atEffectX x: Float, effectZ z: Float) -> Float {
        let worldX = x * EffectSpace.effectToWorldScale
        let worldZ = -z * EffectSpace.effectToWorldScale
        let worldY = world.mapGrid.height(atWorldX: worldX, worldZ: worldZ)
        return EffectSpace.toEffectHeight(worldY)
    }

    public func targetState(for targetID: EffectTargetID) -> EffectTargetState? {
        guard let object = world.objects[targetID] else {
            return nil
        }
        return EffectTargetState(
            objectID: object.objectID,
            worldPosition: object.worldPosition,
            headHeight: 2.0,
            facingAngle: 0,
            directionIndex: object.action.direction.rawValue,
            isValid: !object.isDead
        )
    }

    public func playSound(named name: String, atWorldPosition position: SIMD3<Float>?, delay: TimeInterval) {
        audioPlayer.playSoundEffect(named: name, afterDelay: delay)
    }

    public func shakeCamera(amplitude: Float, duration: TimeInterval, frequency: Float) {
        camera.shake(amplitude: amplitude, duration: duration, frequency: frequency)
    }

    public func applyTargetModifier(_ modifier: EffectTargetModifier, to targetID: EffectTargetID) {
    }

    public func spawnChildEffect(_ request: EffectSpawnRequest) {
        guard let effectID = request.effectID else {
            return
        }
        let effect = MapSceneEffect(
            reference: .id(effectID),
            creationTime: CACurrentMediaTime(),
            gridPosition: [Int(request.worldPosition.x), Int(-request.worldPosition.z)],
            worldPosition: request.worldPosition,
            sourceWorldPosition: request.sourceWorldPosition,
            targetObjectID: request.targetObjectID,
            sourceObjectID: request.sourceObjectID,
            ownerObjectID: request.ownerObjectID,
            attachmentKey: request.attachmentKey,
            level: request.level,
            delay: request.delay,
            duration: request.duration
        )
        addEffect(effect)
    }
}
