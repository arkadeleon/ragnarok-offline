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
import RagnarokMetalRendering
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
    let resourceManager: ResourceManager
    weak var gameSession: GameSession?

    let renderer: MetalMapRenderer
    let audioPlayer: MetalMapAudioPlayer

    let mapGrid: MapGrid
    let state: MetalSceneState

    var objects: [GameObjectID: MetalMapObject] = [:]
    var items: [GameObjectID : MetalMapItem] = [:]

    let pathFinder: PathFinder

    var spriteAssetStore: SpriteAssetStore?
    var combatTextSpriteSet: CombatTextSpriteSet?
    var effectAssetStore: EffectAssetStore?
    var effectLoadTasks: [UUID : Task<Void, Never>] = [:]

    var pendingArrivalAction: (@MainActor () -> Void)?
    var arrivalTask: Task<Void, any Error>?

    var cameraState = MapCameraState() {
        didSet {
            updateCamera()
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
        self.resourceManager = resourceManager
        self.gameSession = gameSession
        self.renderer = try MetalMapRenderer()
        self.audioPlayer = MetalMapAudioPlayer(resourceManager: resourceManager)

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
            worldPosition: mapGrid.worldPosition(for: playerPosition)
        )
        objects[metalPlayer.objectID] = metalPlayer

        state.overlay.gauges[player.objectID] = MetalGaugeOverlay(
            id: player.objectID,
            hp: character.hp,
            maxHp: character.maxHp,
            sp: character.sp,
            maxSp: character.maxSp,
            objectType: player.type
        )
    }

    public func load(progress: Progress) async {
        do {
            try await prepareRenderResources(progress: progress)
            await audioPlayer.playBGM(forMapName: mapName)
        } catch {
            logger.warning("Metal map scene failed to load world asset: \(error)")
        }

        addObject(objectID: player.objectID, at: playerPosition, direction: .south, headDirection: .lookForward)
        updateCamera()
    }

    public func unload() {
        arrivalTask?.cancel()
        arrivalTask = nil
        pendingArrivalAction = nil
        audioPlayer.stopAll()
        clearRenderResources()
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
        renderer.tileSelectorResource?.showSelection(at: position, mapGrid: mapGrid)
        gameSession?.requestMove(to: position)
    }

    func resetCamera() {
        cameraState.azimuth = 0
        cameraState.elevation = .pi / 4
    }

    private func nearestObject(ofType type: MapObjectType, fromPosition position: SIMD2<Int>) -> MetalMapObject? {
        objects.values
            .filter {
                $0.type == type
            }
            .min {
                distanceSquared($0.gridPosition, to: position) < distanceSquared($1.gridPosition, to: position)
            }
    }

    private func nearestItem(fromPosition position: SIMD2<Int>) -> MetalMapItem? {
        items.values.min {
            distanceSquared($0.gridPosition, to: position) < distanceSquared($1.gridPosition, to: position)
        }
    }

    private func distanceSquared(_ a: SIMD2<Int>, to b: SIMD2<Int>) -> Int {
        let d = a &- b
        return d.x * d.x + d.y * d.y
    }

    private func onMovementValueChanged(movementValue: CGPoint) {
        guard let playerObject = objects[player.objectID] else {
            return
        }
        let position = playerObject.nextPosition(at: .now) ?? playerObject.gridPosition

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
        if let playerPosition = objects[player.objectID]?.gridPosition,
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

        if let playerPosition = objects[player.objectID]?.gridPosition,
           let target = nearestObject(ofType: .monster, fromPosition: playerPosition) {
            engageMonster(target, skill: skill)
        }
    }

    func pickUpNearestItem() {
        if let playerPosition = objects[player.objectID]?.gridPosition,
           let target = nearestItem(fromPosition: playerPosition) {
            engageItem(target)
        }
    }

    func talkToNearestNPC() {
        if let playerPosition = objects[player.objectID]?.gridPosition,
           let target = nearestObject(ofType: .npc, fromPosition: playerPosition) {
            gameSession?.talkToNPC(npcID: target.objectID)
        }
    }

    private func handleMapObjectSelection(objectID: GameObjectID) {
        guard let target = objects[objectID] else {
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
        let startPosition = objects[player.objectID]?.gridPosition ?? playerPosition
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

extension MetalMapScene {
    func updateCamera() {
        refreshSpriteDrawables()
        updateCameraTarget()
    }

    func prepareFrame() {
        removeExpiredCombatTexts()
        removeExpiredEffects()
        refreshSpriteDrawables()
        updateCameraTarget()
        syncAndProjectOverlay()
    }

    func refreshSpriteDrawables() {
        updateObjectPresentation()
        renderer.spriteDrawables = spriteAssetStore?.sync(
            objects: objects,
            items: items,
            mapGrid: mapGrid,
            cameraState: cameraState
        ) ?? []
    }

    private func updateObjectPresentation() {
        let now = ContinuousClock.now

        for object in objects.values {
            object.update(at: now)
            if let movement = object.movement {
                object.gridPosition = movement.currentPosition
            }
            object.worldPosition = worldPosition(for: object)
        }
    }

    private func worldPosition(for object: MetalMapObject) -> SIMD3<Float> {
        if let movement = object.movement,
           movement.isMoving,
           let movementWorldPosition = movement.worldPosition {
            movementWorldPosition
        } else {
            mapGrid.worldPosition(for: object.gridPosition)
        }
    }

    func updateCameraTarget() {
        let targetPosition: SIMD3<Float>
        if let playerObject = objects[player.objectID] {
            targetPosition = playerObject.worldPosition
        } else {
            targetPosition = mapGrid.worldPosition(for: playerPosition)
        }
        renderer.updateCamera(
            cameraState: cameraState,
            targetPosition: targetPosition
        )
    }

    private func syncAndProjectOverlay() {
        for objectID in state.overlay.gauges.keys {
            guard let object = objects[objectID] else {
                continue
            }
            var worldPosition = object.worldPosition
            worldPosition += [0, -0.8, 0]
            state.overlay.gauges[objectID]?.worldPosition = worldPosition

            let screenPosition = project(worldPosition)
            state.overlay.gauges[objectID]?.screenPosition = screenPosition
        }
    }

    func prepareRenderResources(progress: Progress) async throws {
        let worldAssetLoader = WorldAssetLoader()
        let worldAsset = try await worldAssetLoader.load(
            gat: world.gat,
            gnd: world.gnd,
            rsw: world.rsw,
            resourceManager: resourceManager,
            progress: progress
        )
        let skyboxConfiguration = SkyboxConfiguration.generate(
            light: world.rsw.light,
            mapWidth: mapGrid.width,
            mapHeight: mapGrid.height
        )

        renderer.skyboxResource = SkyboxRenderResource(device: renderer.device, configuration: skyboxConfiguration)
        renderer.groundResource = GroundRenderResource(device: renderer.device, asset: worldAsset.ground)
        renderer.waterResource = WaterRenderResource(device: renderer.device, asset: worldAsset.water)
        renderer.modelResources = worldAsset.modelGroups.map { modelGroup in
            RSMModelRenderResource(
                device: renderer.device,
                prototype: modelGroup.prototype,
                instances: modelGroup.instances
            )
        }

        do {
            let path = ResourcePath.textureDirectory.appending(["grid.tga"])
            let image = try await resourceManager.image(at: path)
            renderer.tileSelectorResource = TileSelectorRenderResource(device: renderer.device, image: image.cgImage)
        } catch {
            logger.warning("Metal map scene failed to load grid.tga: \(error)")
        }

        let scriptContext = await resourceManager.scriptContext
        spriteAssetStore = SpriteAssetStore(
            device: renderer.device,
            resourceManager: resourceManager,
            scriptContext: scriptContext
        )

        do {
            combatTextSpriteSet = try await CombatTextSpriteSet(resourceManager: resourceManager)
        } catch {
            combatTextSpriteSet = nil
            logger.warning("Metal map scene failed to load combat text sprites: \(error)")
        }

        effectAssetStore = EffectAssetStore(
            device: renderer.device,
            resourceManager: resourceManager
        )
    }

    func clearRenderResources() {
        spriteAssetStore?.cancelAllTasks()
        spriteAssetStore = nil
        items.removeAll()
        combatTextSpriteSet = nil
        for task in effectLoadTasks.values {
            task.cancel()
        }
        effectAssetStore?.cancelAllTasks()
        effectAssetStore = nil
        effectLoadTasks.removeAll()

        renderer.skyboxResource = nil
        renderer.groundResource = nil
        renderer.waterResource = nil
        renderer.modelResources.removeAll()
        renderer.spriteDrawables.removeAll()
        renderer.combatTextResources.removeAll()
        renderer.effectResources.removeAll()
        renderer.tileSelectorResource = nil
    }

    private func removeExpiredCombatTexts() {
        let now = ContinuousClock.now
        renderer.combatTextResources = renderer.combatTextResources.filter { _, resource in
            !resource.isExpired(at: now)
        }
    }

    private func removeExpiredEffects() {
        let now = ContinuousClock.now
        renderer.effectResources = renderer.effectResources.filter { _, resource in
            !resource.isExpired(at: now)
        }
    }
}
