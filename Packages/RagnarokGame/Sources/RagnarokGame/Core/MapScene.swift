//
//  MapScene.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/3/27.
//

import AVFAudio
import RagnarokConstants
import RagnarokNetwork
import RagnarokReality
import RagnarokResources
import RagnarokSprite
import RealityKit
import SGLMath
import Spatial
import SwiftUI
import WorldCamera

@MainActor
public class MapScene {
    let mapName: String
    let mapSession: MapSession
    let world: WorldResource
    let player: MapObject
    let playerPosition: SIMD2<Int>

    let mapGrid: MapGrid

    let resourceManager: ResourceManager

    let rootEntity = Entity()
    let worldCameraEntity = Entity()

    var horizontalAngle: Float = radians(0) {
        didSet {
            worldCameraEntity.components[WorldCameraComponent.self]?.azimuth = horizontalAngle
        }
    }

    #if os(visionOS)
    var verticalAngle: Float = radians(15)
    #else
    var verticalAngle: Float = radians(45) {
        didSet {
            worldCameraEntity.components[WorldCameraComponent.self]?.elevation = verticalAngle
        }
    }
    #endif

    var distance: Float = 100 {
        didSet {
            worldCameraEntity.components[WorldCameraComponent.self]?.radius = distance
        }
    }

    private var playerEntity = Entity()
    private let tileSelectorEntity = Entity()

    private let spriteEntityManager: SpriteEntityManager
    private let tileEntityManager: TileEntityManager

    private let pathfinder: Pathfinder

    var tileTapGesture: some Gesture {
        SpatialTapGesture()
            .targetedToEntity(where: .has(TileComponent.self))
            .onEnded { [unowned self] event in
                if let position = event.entity.components[TileComponent.self]?.position {
                    mapSession.requestMove(to: position)
                }
            }
    }

    var mapObjectTapGesture: some Gesture {
        SpatialTapGesture()
            .targetedToEntity(where: .has(MapObjectComponent.self))
            .onEnded { [unowned self] event in
                if let mapObject = event.entity.components[MapObjectComponent.self]?.mapObject {
                    switch mapObject.type {
                    case .monster:
                        let lockOnComponent = LockOnComponent(targetEntity: event.entity, attackRange: 1) {
                            self.mapSession.requestAction(._repeat, onTarget: mapObject.objectID)
                        }
                        playerEntity.components.set(lockOnComponent)

                        let startPosition = playerEntity.gridPosition
                        let endPosition = event.entity.gridPosition
                        let path = pathfinder.findPath(from: startPosition, to: endPosition, within: 1)

                        if path == [startPosition] {
                            mapSession.requestAction(._repeat, onTarget: mapObject.objectID)
                        } else {
                            mapSession.requestMove(to: path.last ?? endPosition)
                        }
                    case .npc:
                        mapSession.talkToNPC(objectID: mapObject.objectID)
                    default:
                        break
                    }
                }
            }
    }

    var mapItemTapGesture: some Gesture {
        SpatialTapGesture()
            .targetedToEntity(where: .has(MapItemComponent.self))
            .onEnded { [unowned self] event in
                if let mapItem = event.entity.components[MapItemComponent.self]?.mapItem {
                    mapSession.pickUpItem(objectID: mapItem.objectID)
                }
            }
    }

    init(mapName: String, mapSession: MapSession, world: WorldResource, player: MapObject, playerPosition: SIMD2<Int>, resourceManager: ResourceManager) {
        self.mapName = mapName
        self.mapSession = mapSession
        self.world = world
        self.player = player
        self.playerPosition = playerPosition

        self.mapGrid = MapGrid(gat: world.gat)

        self.resourceManager = resourceManager

        self.spriteEntityManager = SpriteEntityManager(resourceManager: resourceManager)
        self.tileEntityManager = TileEntityManager(mapGrid: mapGrid, rootEntity: rootEntity)

        self.pathfinder = Pathfinder(mapGrid: mapGrid)

        GridPositionComponent.registerComponent()
        MapItemComponent.registerComponent()
        MapObjectComponent.registerComponent()
        TileComponent.registerComponent()

        LockOnComponent.registerComponent()
        LockOnSystem.registerSystem()

        SpriteAnimationsComponent.registerComponent()
        SpriteActionComponent.registerComponent()
        SpriteSystem.registerSystem()

        WalkingComponent.registerComponent()
        WalkingSystem.registerSystem()

        PlaySpriteAnimationAction.registerAction()
        PlaySpriteAnimationActionHandler.register { _ in
            PlaySpriteAnimationActionHandler()
        }
    }

    func load(progress: Progress) async {
        if let worldEntity = try? await Entity(from: world, resourceManager: resourceManager, progress: progress) {
            worldEntity.name = mapName
            worldEntity.transform = Transform(rotation: simd_quatf(angle: radians(-90), axis: [1, 0, 0]))

            if let audioResource = await audioResource(forMapName: mapName) {
                worldEntity.components.set(AudioLibraryComponent(resources: [
                    "BGM": audioResource
                ]))
                worldEntity.components.set(AmbientAudioComponent())
                worldEntity.playAudio(audioResource)
            }

            rootEntity.addChild(worldEntity)
        }

        tileEntityManager.addTileEntities(forCenter: playerPosition)

        do {
            let path = ResourcePath.textureDirectory.appending(["grid.tga"])
            let image = try await resourceManager.image(at: path)

            let options = TextureResource.CreateOptions(semantic: .color)
            let texture = try await TextureResource(image: image, withName: "tile.selector", options: options)

            var material = UnlitMaterial(texture: texture)
            material.blending = .transparent(opacity: 1.0)
            material.opacityThreshold = 0.0001

            tileSelectorEntity.components.set(
                ModelComponent(mesh: .generatePlane(width: 1, height: 1), materials: [material])
            )
            tileSelectorEntity.isEnabled = false

            rootEntity.addChild(tileSelectorEntity)
        } catch {
            logger.warning("\(error)")
        }

        do {
            playerEntity = try await Entity(from: player, resourceManager: resourceManager)
            playerEntity.name = "\(player.objectID)"
            playerEntity.transform = transform(for: playerPosition)
            playerEntity.components.set([
                GridPositionComponent(gridPosition: playerPosition),
                MapObjectComponent(mapObject: player),
            ])
        } catch {
            logger.warning("\(error)")
        }

        playerEntity.playSpriteAnimation(.idle, direction: .south, repeats: true)

        rootEntity.addChild(playerEntity)

        spriteEntityManager.addEntity(playerEntity, forObjectID: player.objectID)

        setupLighting()
        setupWorldCamera(target: playerEntity)

        mapSession.notifyMapLoaded()
    }

    func unload() {
        if let worldEntity = rootEntity.findEntity(named: mapName) {
            worldEntity.stopAllAudio()
        }
    }

    func raycast(origin: SIMD3<Float>, direction: SIMD3<Float>, in scene: RealityKit.Scene) {
        let hitEntity = scene.raycast(origin: origin, direction: direction, length: 150, query: .nearest).first?.entity.parent
        if let hitEntity {
            if let mapObject = hitEntity.components[MapObjectComponent.self]?.mapObject {
                switch mapObject.type {
                case .monster:
                    let lockOnComponent = LockOnComponent(targetEntity: hitEntity, attackRange: 1) {
                        self.mapSession.requestAction(._repeat, onTarget: mapObject.objectID)
                    }
                    playerEntity.components.set(lockOnComponent)

                    let startPosition = playerEntity.gridPosition
                    let endPosition = hitEntity.gridPosition
                    let path = pathfinder.findPath(from: startPosition, to: endPosition, within: 1)

                    if path == [startPosition] {
                        mapSession.requestAction(._repeat, onTarget: mapObject.objectID)
                    } else {
                        mapSession.requestMove(to: path.last ?? endPosition)
                    }
                case .npc:
                    mapSession.talkToNPC(objectID: mapObject.objectID)
                default:
                    break
                }
            } else if let mapItem = hitEntity.components[MapItemComponent.self]?.mapItem {
                mapSession.pickUpItem(objectID: mapItem.objectID)
            }
            return
        }

        var point = origin
        for i in 0..<200 {
            point = origin + direction * Float(i)

            let x = point.x
            let y = point.y

            let position: SIMD2<Int> = [Int(x), Int(y)]

            guard 0..<mapGrid.width ~= position.x, 0..<mapGrid.height ~= position.y else {
                continue
            }

            let cell = mapGrid[position]

            let xr = x.truncatingRemainder(dividingBy: 1)
            let yr = y.truncatingRemainder(dividingBy: 1)

            let x1 = cell.bottomLeftAltitude + (cell.bottomRightAltitude - cell.bottomLeftAltitude) * xr
            let x2 = cell.topLeftAltitude + (cell.topRightAltitude - cell.topLeftAltitude) * xr

            let altitude = x1 + (x2 - x1) * yr

            if fabsf(altitude - point.z) < 0.5 {
                mapSession.requestMove(to: position)

                let p0: SIMD3<Float> = [Float(position.x), Float(position.y), cell.bottomLeftAltitude + 0.1]
                let p1: SIMD3<Float> = [Float(position.x + 1), Float(position.y), cell.bottomRightAltitude + 0.1]
                let p2: SIMD3<Float> = [Float(position.x + 1), Float(position.y + 1), cell.topRightAltitude + 0.1]
                let p3: SIMD3<Float> = [Float(position.x), Float(position.y + 1), cell.topLeftAltitude + 0.1]

                let t0: SIMD2<Float> = [0, 0]
                let t1: SIMD2<Float> = [1, 0]
                let t2: SIMD2<Float> = [1, 1]
                let t3: SIMD2<Float> = [0, 1]

                var descriptor = MeshDescriptor(name: "tile.selector")
                descriptor.materials = .allFaces(0)
                descriptor.primitives = .triangles([0, 1, 2, 2, 3, 0])
                descriptor.positions = MeshBuffer([p0, p1, p2, p3])
                descriptor.textureCoordinates = MeshBuffer([t0, t1, t2, t3])

                Task {
                    let mesh = try await MeshResource(from: [descriptor])
                    tileSelectorEntity.components[ModelComponent.self]?.mesh = mesh
                    tileSelectorEntity.isEnabled = true

                    let disableEntityAction = SetEntityEnabledAction(isEnabled: false)
                    let disableEntityAnimation = try AnimationResource.makeActionAnimation(for: disableEntityAction, duration: 1 / 30, delay: 0.5)
                    tileSelectorEntity.playAnimation(disableEntityAnimation)
                }

                break
            }
        }
    }

    private func setupLighting() {
        let lightEntity = Entity()

        let diffuse = [
            world.rsw.light.diffuseRed,
            world.rsw.light.diffuseGreen,
            world.rsw.light.diffuseBlue,
        ]
        let lightColor = DirectionalLightComponent.Color(
            red: CGFloat(diffuse[0]),
            green: CGFloat(diffuse[1]),
            blue: CGFloat(diffuse[2]),
            alpha: 1
        )
        let lightComponent = DirectionalLightComponent(color: lightColor, intensity: 3000)

        let lightShadowComponent = DirectionalLightComponent.Shadow(maximumDistance: 150)

        lightEntity.components.set([lightComponent, lightShadowComponent])

        let longitude = radians(Double(world.rsw.light.longitude))
        let latitude = radians(Double(world.rsw.light.latitude))

        let target: SIMD3<Float> = [0, 0, 0]
        var position: SIMD3<Float> = [0, 0, 1]
        var point = Point3D(position)
        point = point.rotated(
            by: simd_quatd(angle: latitude, axis: [1, 0, 0]),
            around: Point3D(target)
        )
        point = point.rotated(
            by: simd_quatd(angle: -longitude, axis: [0, 1, 0]),
            around: Point3D(target)
        )
        position = SIMD3(point)

        lightEntity.look(at: target, from: position, relativeTo: nil)

        rootEntity.addChild(lightEntity)
    }

    /// Performs any necessary setup of the world camera.
    /// - Parameter target: The entity to orient the camera toward.
    private func setupWorldCamera(target: Entity) {
        // Set the available bounds for the camera orientation.
        let elevationBounds: ClosedRange<Float> = radians(15)...radians(60)
        let initialElevation = verticalAngle

        // Create a world camera component, which acts as a target camera,
        // where it repositions the scene to orient toward the owning entity.
        var worldCameraComponent = WorldCameraComponent(
            azimuth: 0,
            elevation: initialElevation,
            radius: 3,
            bounds: WorldCameraComponent.CameraBounds(elevation: elevationBounds)
        )
        #if os(visionOS)
        // The way that RealityKit orients immersive views isn't the same as a portal.
        // This offset brings the target a bit closer to the center of the view.
        // The system also modifies this in `PyroPandaView/RealityView`.
        worldCameraComponent.radius = 15
        worldCameraComponent.targetOffset = [0, -0.75, 0]
        #else
        worldCameraComponent.radius = 100
        worldCameraComponent.targetOffset = [0, 0.5, 0]
        #endif

        let followComponent = FollowComponent(targetId: target.id, smoothing: [3, 1.2, 3])

        worldCameraEntity.components.set([worldCameraComponent, followComponent])
        worldCameraEntity.name = "camera"
        #if !os(visionOS)
        worldCameraEntity.addChild(
            Entity(components: PerspectiveCameraComponent(near: 2, far: 300, fieldOfViewInDegrees: 15))
        )
        #endif

        let simulationEntity = PhysicsSimulationComponent.nearestSimulationEntity(for: target)
        let parentEntity = simulationEntity ?? target.parent
        worldCameraEntity.setParent(parentEntity)

        worldCameraEntity.position = target.position(relativeTo: parentEntity)
    }

    private func transform(for gridPosition: SIMD2<Int>) -> Transform {
        let translation = position(for: gridPosition)
        let transform = Transform(translation: translation)
        return transform
    }

    private func position(for gridPosition: SIMD2<Int>) -> SIMD3<Float> {
        let altitude = mapGrid[gridPosition].averageAltitude
        let position: SIMD3<Float> = [
            Float(gridPosition.x) + 0.5,
            Float(gridPosition.y) + 0.5,
            altitude,
        ]
        return position
    }

    private func audioResource(forMapName mapName: String) async -> AudioResource? {
        let mp3NameTable = await resourceManager.mp3NameTable()
        guard let mp3Name = mp3NameTable.mp3Name(forMapName: mapName) else {
            return nil
        }

        let bgmPath = ResourcePath(components: ["BGM", mp3Name])
        guard let bgmData = try? await resourceManager.contentsOfResource(at: bgmPath) else {
            return nil
        }

        guard let audioBuffer = audioBuffer(with: bgmData) else {
            return nil
        }

        let configuration = AudioBufferResource.Configuration(shouldLoop: true)
        let audioResource = try? AudioBufferResource(buffer: audioBuffer, configuration: configuration)
        return audioResource
    }

    private func audioBuffer(with data: Data) -> AVAudioBuffer? {
        // Create a temporary file
        let uuid = UUID().uuidString
        let tempURL = URL.temporaryDirectory.appending(path: uuid)

        do {
            try data.write(to: tempURL)
            let audioFile = try AVAudioFile(forReading: tempURL)

            let buffer = AVAudioPCMBuffer(
                pcmFormat: audioFile.processingFormat,
                frameCapacity: AVAudioFrameCount(audioFile.length)
            )

            if let buffer {
                try audioFile.read(into: buffer)
            }

            // Clean up
            try? FileManager.default.removeItem(at: tempURL)

            return buffer
        } catch {
            try? FileManager.default.removeItem(at: tempURL)
            return nil
        }
    }
}

extension MapScene {
    func onMovementValueChanged(movementValue: CGPoint) {
        let position: SIMD2<Int>
        if let path = playerEntity.components[WalkingComponent.self]?.path, path.count > 1 {
            position = path[1]
        } else {
            position = playerEntity.gridPosition
        }

        // SwiftUI screen-space: origin at top-left, +x right, +y down.
        // Game grid-space: origin bottom-left, +x east, +y north.
        // We first flip the Y axis to get a Cartesian vector, rotate it by the
        // negative camera azimuth, then flip Y back so the thresholds below
        // still use “north is positive Y”.
        //
        //            screen-space (SwiftUI)
        //                ^ -Y (up)
        //                |
        //   -X (left) <--+--> +X (right)
        //                |
        //                v +Y (down)
        //
        // After flip + rotate:
        //
        //                ^ +Y (north)
        //                |
        //   -X (west) <--+--> +X (east)
        //                |
        //                v -Y (south)
        let joystickInput = SIMD2<Float>(
            Float(movementValue.x),
            Float(-movementValue.y)
        )
        let angle = -horizontalAngle
        // Rotate the joystick vector to align with the camera azimuth.
        // We use the standard 2D rotation matrix:
        // [ x' ]   [ cosθ  -sinθ ] [ x ]
        // [ y' ] = [ sinθ   cosθ ] [ y ]
        // where θ is the horizontal camera angle (clockwise pan increases the angle,
        // so we rotate by -θ to recover world-space directions).
        let cosAngle = cos(angle)
        let sinAngle = sin(angle)
        let worldInput = SIMD2<Float>(
            joystickInput.x * cosAngle - joystickInput.y * sinAngle,
            joystickInput.x * sinAngle + joystickInput.y * cosAngle
        )

        // Use a constant stride once the joystick leaves the dead zone so players
        // always advance three tiles in the intended direction, regardless of camera.
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
            mapSession.requestMove(to: newPosition)
        }
    }
}

extension MapScene: MapEventHandlerProtocol {
    func onPlayerMoved(startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) {
        if var walkingComponent = playerEntity.components[WalkingComponent.self],
           walkingComponent.path.count > 1 {
            let startPosition = walkingComponent.path[1]
            let path = pathfinder.findPath(from: startPosition, to: endPosition)

            walkingComponent.path = [walkingComponent.path[0]] + path
            playerEntity.components.set(walkingComponent)
        } else {
            let startPosition = playerEntity.gridPosition
            let path = pathfinder.findPath(from: startPosition, to: endPosition)

            let walkingComponent = WalkingComponent(path: path, mapGrid: mapGrid)
            playerEntity.components.set(walkingComponent)
        }

        tileEntityManager.updateTileEntities(forCenter: endPosition)
    }

    func onMapObjectSpawned(object: MapObject, position: SIMD2<Int>, direction: Direction, headDirection: HeadDirection) {
        Task {
            let (entity, isNew) = try await spriteEntityManager.entity(for: object)

            if isNew {
                entity.name = "\(object.objectID)"
                entity.transform = transform(for: position)
                entity.isEnabled = (object.effectState != .cloak)
                entity.components.set([
                    GridPositionComponent(gridPosition: position),
                    MapObjectComponent(mapObject: object),
                ])
                rootEntity.addChild(entity)
            } else {
                entity.transform = transform(for: position)
                entity.components[GridPositionComponent.self]?.gridPosition = position
                entity.components.remove(WalkingComponent.self)
            }

            entity.playSpriteAnimation(.idle, direction: CharacterDirection(direction: direction), repeats: true)
        }
    }

    func onMapObjectMoved(object: MapObject, startPosition: SIMD2<Int>, endPosition: SIMD2<Int>) {
        Task {
            let (entity, isNew) = try await spriteEntityManager.entity(for: object)

            if isNew {
                entity.name = "\(object.objectID)"
                entity.transform = transform(for: endPosition)
                entity.isEnabled = (object.effectState != .cloak)
                entity.components.set([
                    GridPositionComponent(gridPosition: startPosition),
                    MapObjectComponent(mapObject: object),
                ])
                rootEntity.addChild(entity)
            }

            if var walkingComponent = entity.components[WalkingComponent.self],
               walkingComponent.path.count > 1 {
                let startPosition = walkingComponent.path[1]
                let path = pathfinder.findPath(from: startPosition, to: endPosition)

                walkingComponent.path = [walkingComponent.path[0]] + path
                entity.components.set(walkingComponent)
            } else {
                let startPosition = entity.gridPosition
                let path = pathfinder.findPath(from: startPosition, to: endPosition)

                let walkingComponent = WalkingComponent(path: path, mapGrid: mapGrid)
                entity.components.set(walkingComponent)
            }
        }
    }

    func onMapObjectStopped(objectID: UInt32, position: SIMD2<Int>) {
        Task {
            if let entity = try await spriteEntityManager.entity(forOjectID: objectID) {
                entity.transform = transform(for: position)
                entity.components[GridPositionComponent.self]?.gridPosition = position
                entity.components.remove(WalkingComponent.self)
                entity.playSpriteAnimation(.idle, direction: .south, repeats: true)
            }
        }
    }

    func onMapObjectVanished(objectID: UInt32) {
        Task {
            try await spriteEntityManager.removeEntity(forObjectID: objectID)
        }
    }

    func onMapObjectStateChanged(objectID: UInt32, bodyState: StatusChangeOption1, healthState: StatusChangeOption2, effectState: StatusChangeOption) {
        Task {
            if let entity = try await spriteEntityManager.entity(forOjectID: objectID) {
                entity.isEnabled = (effectState != .cloak)
            }
        }
    }

    func onMapObjectActionPerformed(sourceObjectID: UInt32, targetObjectID: UInt32, actionType: DamageType) {
        Task {
            if let entity = try await spriteEntityManager.entity(forOjectID: sourceObjectID) {
                switch actionType {
                case .normal, .endure, .multi_hit, .multi_hit_endure, .critical, .lucy_dodge, .multi_hit_critical:
                    entity.attack(direction: .south)
                case .pickup_item:
                    entity.playSpriteAnimation(.pickup, direction: .south, repeats: false)
                case .sit_down:
                    entity.playSpriteAnimation(.sit, direction: .south, repeats: true)
                case .stand_up:
                    entity.playSpriteAnimation(.idle, direction: .south, repeats: true)
                default:
                    break
                }
            }
        }
    }

    func onItemSpawned(item: MapItem, position: SIMD2<Int>) {
        Task {
            let entity = try await Entity(from: item, resourceManager: resourceManager)
            entity.name = "\(item.objectID)"
            entity.transform = transform(for: position)
            entity.components.set([
                GridPositionComponent(gridPosition: position),
                MapItemComponent(mapItem: item),
            ])

            entity.playDefaultSpriteAnimation(repeats: true)

            rootEntity.addChild(entity)
        }
    }

    func onItemVanished(objectID: UInt32) {
        if let entity = rootEntity.findEntity(named: "\(objectID)") {
            entity.removeFromParent()
        }
    }
}
