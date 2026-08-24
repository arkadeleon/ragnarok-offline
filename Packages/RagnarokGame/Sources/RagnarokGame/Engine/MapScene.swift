//
//  MapScene.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import CoreGraphics
import Foundation
import Metal
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

private enum MapMovementDecision {
    case alreadyInRange
    case moveTo(SIMD2<Int>)
    case noPath
}

@MainActor
public final class MapScene {
    public let mapName: String

    let world: WorldResource
    let player: MapSceneMapObject
    let resourceManager: ResourceManager
    let renderResources: MapSceneRenderResources
    weak var gameSession: GameSession?

    let audioPlayer: MapAudioPlayer

    let mapGrid: MapGrid
    let state: MapSceneState

    var objects: [GameObjectID: MapSceneMapObject] = [:]
    var items: [GameObjectID : MapSceneDroppedItem] = [:]

    /// The objects that show a gauge above them.
    var gaugeObjectIDs: Set<GameObjectID> = []

    let pathFinder: PathFinder

    var combatTexts: [UUID : CombatText] = [:]

    var effects: [UUID : MapSceneEffect] = [:]

    var fog: Fog = .disabled
    var tileSelector: TileSelector?

    var pendingArrivalAction: (@MainActor () -> Void)?
    var arrivalTask: Task<Void, any Error>?

    var cameraState = MapCameraState()
    private var cameraTargetPosition: SIMD3<Float> = .zero
    var lastCamera: RenderCamera?

    init(
        mapName: String,
        world: WorldResource,
        account: AccountInfo,
        character: CharacterInfo,
        playerPosition: SIMD2<Int>,
        resourceManager: ResourceManager,
        renderResources: MapSceneRenderResources,
        gameSession: GameSession
    ) {
        self.mapName = mapName
        self.world = world
        self.resourceManager = resourceManager
        self.renderResources = renderResources
        self.gameSession = gameSession
        self.audioPlayer = MapAudioPlayer(resourceManager: resourceManager)

        self.mapGrid = MapGrid(gat: world.gat)
        self.state = MapSceneState()

        self.pathFinder = PathFinder(mapGrid: self.mapGrid)

        self.player = MapSceneMapObject(
            account: account,
            character: character,
            gridPosition: playerPosition,
            direction: .south,
            headDirection: .lookForward
        )
        objects[player.objectID] = player

        gaugeObjectIDs.insert(player.objectID)
    }

    public func load(progress: Progress) async throws {
        do {
            try await prepareRenderResources(progress: progress)
            await audioPlayer.playBGM(forMapName: mapName)
        } catch {
            logger.warning("Map scene failed to load world asset: \(error)")
        }
    }

    public func unload() {
        arrivalTask?.cancel()
        arrivalTask = nil
        pendingArrivalAction = nil
        audioPlayer.stopAll()
        clearRenderResources()
    }

    func prepareRenderResources(progress: Progress) async throws {
        let worldAssetLoader = WorldAssetLoader()
        let worldAsset = try await worldAssetLoader.load(
            world: world,
            resourceManager: resourceManager,
            progress: progress
        )

        let fogParameterTable = await resourceManager.fogParameterTable()
        if let parameter = fogParameterTable.fogParameter(forMapName: mapName) {
            fog = Fog(near: parameter.near, far: parameter.far, color: parameter.color.rgb)
        }

        renderResources.loadWorld(worldAsset)

        do {
            let path = ResourcePath.textureDirectory.appending(["grid.tga"])
            let image = try await resourceManager.image(at: path)
            renderResources.loadTileSelectorTexture(from: image.cgImage)
        } catch {
            logger.warning("Map scene failed to load grid.tga: \(error)")
        }

        renderResources.prepareSprites(resourceManager: resourceManager)

        do {
            try await renderResources.prepareCombatTexts(resourceManager: resourceManager)
        } catch {
            logger.warning("Map scene failed to load combat text sprites: \(error)")
        }

        renderResources.prepareEffects(resourceManager: resourceManager)
    }

    func clearRenderResources() {
        items.removeAll()

        combatTexts.removeAll()

        effects.removeAll()

        tileSelector = nil
        renderResources.removeAll()

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
    private static let cameraTargetOffset = SIMD3<Float>(0, 0.5, 0)
    private static let cameraFieldOfViewDegrees: Float = 15

    /// The game camera, orbiting the player at `cameraState` and drawn into `viewport`.
    ///
    /// iOS and macOS draw the map from this camera. visionOS draws it from the eye instead,
    /// and uses this camera's view matrix to place the map around the viewer.
    func makeCamera(viewport: MTLViewport) -> RenderCamera {
        let worldTarget = MapSceneRenderer.renderPosition(for: cameraTargetPosition) + Self.cameraTargetOffset

        let cameraOrientation =
            simd_quatf(angle: -cameraState.azimuth, axis: [0, 1, 0]) *
            simd_quatf(angle: -cameraState.elevation, axis: [1, 0, 0])
        let cameraPosition = worldTarget + cameraOrientation.act([0, 0, cameraState.distance])
        let cameraUp = cameraOrientation.act([0, 1, 0])

        let viewportHeight = max(Float(viewport.height), 1)
        let aspectRatio = max(Float(viewport.width) / viewportHeight, .leastNonzeroMagnitude)
        let farZ = max(cameraState.distance * 4, 1000)

        return RenderCamera(
            viewMatrix: lookAt(cameraPosition, worldTarget, cameraUp),
            projectionMatrix: perspective(radians(Self.cameraFieldOfViewDegrees), aspectRatio, 0.1, farZ),
            position: cameraPosition,
            azimuth: cameraState.azimuth,
            elevation: cameraState.elevation
        )
    }

    func update(
        at now: ContinuousClock.Instant,
        renderTime: TimeInterval
    ) {
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
            renderResources.removeCombatText(id: combatTextObjectID)
        }

        for effectObjectID in renderResources.expiredEffectIDs(atTime: renderTime) {
            removeEffect(objectID: effectObjectID)
        }

        for object in objects.values {
            object.update(at: now)
            if let movement = object.movement {
                object.gridPosition = movement.currentPosition
            }
        }

        cameraTargetPosition = worldPosition(for: player)
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
