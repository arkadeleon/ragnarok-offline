//
//  MapSceneRuntime.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/8/24.
//

import Foundation
import Metal
import RagnarokCore
import RagnarokRenderAssets
import RagnarokRendering
import RagnarokResources
import simd

@MainActor
final class MapSceneRuntime {
    private static let cameraTargetOffset = SIMD3<Float>(0, 0.5, 0)
    private static let cameraFieldOfViewDegrees: Float = 15

    let scene: MapScene
    let world: WorldResource
    let renderResources: MapSceneRenderResources
    var lastCamera: RenderCamera?

    init(
        scene: MapScene,
        world: WorldResource,
        renderResources: MapSceneRenderResources
    ) {
        self.scene = scene
        self.world = world
        self.renderResources = renderResources
    }

    func load(progress: Progress) async throws {
        let worldAssetLoader = WorldAssetLoader()
        let worldAsset = try await worldAssetLoader.load(
            world: world,
            resourceManager: scene.resourceManager,
            progress: progress
        )

        scene.sounds = world.rsw.sounds.map { sound in
            MapSceneSound(sound: sound, gnd: world.gnd)
        }

        let fogParameterTable = await scene.resourceManager.fogParameterTable()
        if let parameter = fogParameterTable.fogParameter(forMapName: scene.mapName) {
            scene.fog = Fog(near: parameter.near, far: parameter.far, color: parameter.color.rgb)
        }

        renderResources.loadWorld(worldAsset)

        renderResources.prepareSprites()

        do {
            try await renderResources.prepareCombatTexts(resourceManager: scene.resourceManager)
        } catch {
            logger.warning("Map scene failed to load combat text sprites: \(error)")
        }

        renderResources.prepareEffects(resourceManager: scene.resourceManager)

        await scene.load()
    }

    func unload() {
        scene.unload()
        renderResources.removeAll()
        lastCamera = nil
    }

    func update(at now: ContinuousClock.Instant, renderTime: TimeInterval) {
        scene.update(at: now)

        for effectID in renderResources.expiredEffectIDs(atTime: renderTime) {
            scene.removeEffect(objectID: effectID)
        }

        renderResources.synchronizeSprites(
            objects: scene.objects,
            items: scene.items,
            worldPositions: makeWorldPositions()
        )

        renderResources.synchronizeCombatTexts(scene.combatTexts)

        let effectWorldPositions = scene.effects.mapValues { effect in
            scene.mapGrid.worldPosition(for: effect.gridPosition)
        }
        renderResources.synchronizeEffects(
            scene.effects,
            worldPositions: effectWorldPositions
        ) { [audioPlayer = scene.audioPlayer] soundName, delay in
            audioPlayer.playSoundEffect(named: soundName, after: .seconds(delay))
        }
    }

    /// The game camera, orbiting the player at `cameraState` and drawn into `viewport`.
    ///
    /// iOS and macOS draw the map from this camera. visionOS draws it from the eye instead,
    /// and uses this camera's view matrix to place the map around the viewer.
    func makeCamera(viewport: MTLViewport) -> RenderCamera {
        let cameraState = scene.cameraState
        let targetPosition = scene.worldPosition(for: scene.player)
        let worldTarget = MapSceneRenderer.renderPosition(for: targetPosition) + Self.cameraTargetOffset

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

    func makeRenderSnapshot(at now: ContinuousClock.Instant) -> MapSceneRenderSnapshot {
        let worldPositions = makeWorldPositions()

        var snapshot = MapSceneRenderSnapshot(fog: scene.fog)

        snapshot.world = renderResources.world
        snapshot.spriteDrawables = renderResources.spriteDrawables

        if let tileSelector = scene.tileSelector,
           !tileSelector.isExpired(at: now),
           scene.mapGrid.contains(tileSelector.position) {
            snapshot.tileSelector = MapSceneRenderSnapshot.TileSelector(
                position: tileSelector.position,
                cell: scene.mapGrid[tileSelector.position]
            )
        }

        snapshot.effects = scene.effects.values
            .compactMap { effect in
                guard let resourceGroup = renderResources.effectResource(for: effect.id) else {
                    return nil
                }
                return MapSceneRenderSnapshot.Effect(
                    resourceGroup: resourceGroup,
                    attachedWorldPosition: effect.targetObjectID.flatMap { worldPositions[$0] }
                )
            }
            .sorted {
                $0.resourceGroup.creationTime < $1.resourceGroup.creationTime
            }

        snapshot.bars = scene.hpspBarObjectIDs.compactMap { objectID in
            guard let object = scene.objects[objectID],
                  object.effectState != .cloak,
                  let worldPosition = worldPositions[objectID] else {
                return nil
            }
            let mesh = BarMesh.mesh(
                hp: object.hp,
                maxHp: object.maxHp,
                sp: object.sp,
                maxSp: object.maxSp,
                objectType: object.type
            )
            guard !mesh.vertices.isEmpty else {
                return nil
            }
            return MapSceneRenderSnapshot.Bar(
                vertices: mesh.vertices,
                worldPosition: worldPosition + [0, 0, -0.8]
            )
        }

        snapshot.bars += scene.objects.values.compactMap { object in
            guard let cast = object.cast,
                  object.effectState != .cloak,
                  let worldPosition = worldPositions[object.objectID] else {
                return nil
            }
            let mesh = BarMesh.mesh(cast: cast, time: now)
            return MapSceneRenderSnapshot.Bar(
                vertices: mesh.vertices,
                worldPosition: worldPosition
            )
        }

        // A target shows one combo text at a time: the newest one that has started
        // hides the ones before it.
        let comboTexts = scene.combatTexts.values
            .filter { $0.kind.isCombo && $0.startTime <= now }
            .map { ($0.target.objectID, $0) }
        let latestComboTexts = Dictionary(
            comboTexts,
            uniquingKeysWith: { $0.startTime > $1.startTime ? $0 : $1 }
        )

        snapshot.combatTexts = scene.combatTexts.values
            .filter { combatText in
                if combatText.kind.isCombo, let latestComboText = latestComboTexts[combatText.target.objectID] {
                    return combatText.id == latestComboText.id
                } else {
                    return true
                }
            }
            .sorted {
                $0.creationTime < $1.creationTime
            }
            .compactMap { combatText in
                guard let resource = renderResources.combatTextResource(for: combatText.id) else {
                    return nil
                }

                let anchor = worldPositions[combatText.target.objectID] ?? combatText.target.initialWorldPosition
                guard let animation = combatText.animation(
                    at: now,
                    anchor: anchor,
                    cameraAzimuth: scene.cameraState.azimuth
                ) else {
                    return nil
                }

                return MapSceneRenderSnapshot.CombatText(
                    vertices: resource.makeVertices(scale: animation.scale, alpha: animation.alpha),
                    worldPosition: animation.worldPosition,
                    texture: resource.texture
                )
            }

        return snapshot
    }

    private func makeWorldPositions() -> [GameObjectID : SIMD3<Float>] {
        var worldPositions: [GameObjectID : SIMD3<Float>] = [:]
        worldPositions.reserveCapacity(scene.objects.count + scene.items.count)

        for object in scene.objects.values {
            worldPositions[object.objectID] = scene.worldPosition(for: object)
        }

        for item in scene.items.values {
            worldPositions[item.objectID] = scene.mapGrid.worldPosition(for: item.gridPosition)
        }

        return worldPositions
    }
}
