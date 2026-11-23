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
    private var lastUpdateTime: TimeInterval?

    init(
        scene: MapScene,
        world: WorldResource,
        renderResources: MapSceneRenderResources
    ) {
        self.scene = scene
        self.world = world
        self.renderResources = renderResources

        scene.observer = renderResources
    }

    func load(progress: Progress) async throws {
        let worldAssetLoader = WorldAssetLoader()
        let worldAsset = try await worldAssetLoader.load(
            world: world,
            resourceManager: scene.resourceManager,
            progress: progress
        )

        renderResources.loadWorld(worldAsset)

        renderResources.prepareSprites(shadowmap: GroundShadowmap(gnd: world.gnd))
        await renderResources.prepareCombatTexts(resourceManager: scene.resourceManager)
        await renderResources.prepareEffects(resourceManager: scene.resourceManager) { [audioPlayer = scene.audioPlayer] soundName, delay in
            audioPlayer.playSoundEffect(named: soundName, afterDelay: delay)
        }
        await renderResources.loadWorldEffects(worldAsset.effects)

        await scene.load(world: world)
    }

    func unload() {
        scene.unload()
        renderResources.removeAll()
        lastCamera = nil
        lastUpdateTime = nil
    }

    func update(atTime currentTime: TimeInterval) {
        let deltaTime = lastUpdateTime.map { min(max(currentTime - $0, 0), 0.1) } ?? 0
        lastUpdateTime = currentTime

        let worldTime = MapWorldTime(time: currentTime, deltaTime: deltaTime)
        scene.update(atTime: worldTime)
        renderResources.updateEffects(atTime: currentTime, world: scene)

        for instanceID in renderResources.expiredEffectInstanceIDs(atTime: currentTime) {
            scene.removeEffect(instanceID: instanceID)
        }

        renderResources.synchronizeSprites(objects: scene.world.objects, items: scene.world.items)
    }

    /// Builds the render camera from the scene camera's settings and smoothed focus.
    ///
    /// iOS and macOS draw the map from this camera. visionOS draws it from the eye instead,
    /// and uses this camera's view matrix to place the map around the viewer.
    func makeCamera(viewport: MTLViewport) -> RenderCamera {
        let camera = scene.camera
        let targetPosition = camera.target ?? scene.world.player.worldPosition
        let worldTarget = targetPosition + Self.cameraTargetOffset + camera.shakeOffset

        let viewportHeight = max(Float(viewport.height), 1)
        let aspectRatio = max(Float(viewport.width) / viewportHeight, .leastNonzeroMagnitude)
        #if os(visionOS)
        let nearZ: Float = 0.1
        #else
        let nearZ: Float = max(0.5, min(2.0, camera.distance * 0.1))
        #endif
        let farZ = max(camera.distance * 4, 1000)

        let cameraOrientation =
            simd_quatf(angle: -camera.azimuth, axis: [0, 1, 0]) *
            simd_quatf(angle: -camera.elevation, axis: [1, 0, 0])
        var cameraPosition = worldTarget + cameraOrientation.act([0, 0, camera.distance])
        let cameraUp = cameraOrientation.act([0, 1, 0])

        let forward = simd_normalize(worldTarget - cameraPosition)
        let nearPlanePosition = cameraPosition + forward * nearZ
        let terrainHeight = max(
            scene.world.mapGrid.height(atWorldX: cameraPosition.x, worldZ: cameraPosition.z),
            scene.world.mapGrid.height(atWorldX: nearPlanePosition.x, worldZ: nearPlanePosition.z)
        )
        let minimumCameraY = terrainHeight + max(0.5, nearZ * 1.25)
        if cameraPosition.y < minimumCameraY {
            cameraPosition.y = minimumCameraY
        }
        scene.lastCameraWorldPosition = cameraPosition

        let offset = cameraPosition - worldTarget
        let horizontalDistance = simd_length(SIMD2<Float>(offset.x, offset.z))
        let effectiveElevation = horizontalDistance > .leastNonzeroMagnitude
            ? atan2(offset.y, horizontalDistance)
            : camera.elevation

        return RenderCamera(
            viewMatrix: lookAt(cameraPosition, worldTarget, cameraUp),
            projectionMatrix: perspective(radians(Self.cameraFieldOfViewDegrees), aspectRatio, nearZ, farZ),
            position: cameraPosition,
            azimuth: camera.azimuth,
            elevation: effectiveElevation
        )
    }

    func makeRenderSnapshot(atTime currentTime: TimeInterval) -> MapSceneRenderSnapshot {
        var snapshot = MapSceneRenderSnapshot(fog: scene.world.fog)
        snapshot.world = renderResources.world
        snapshot.tileSelector = makeTileSelector(atTime: currentTime)
        snapshot.targetSelector = makeTargetSelector(atTime: currentTime)
        snapshot.spriteDrawables = renderResources.spriteDrawables
        snapshot.effects = makeEffects(atTime: currentTime)
        snapshot.strEffectPayloads = renderResources.collectSTRPayloads(fog: scene.world.fog, world: scene)
        snapshot.bars = makeBars(atTime: currentTime)
        snapshot.texts = makeTexts()
        snapshot.combatTexts = makeCombatTexts(atTime: currentTime)
        snapshot.combatTextTexture = renderResources.combatTextTexture
        return snapshot
    }

    private func makeTileSelector(atTime currentTime: TimeInterval) -> MapSceneRenderSnapshot.TileSelector? {
        guard let tileSelector = scene.tileSelector,
              !tileSelector.isExpired(atTime: currentTime),
              scene.world.mapGrid.contains(tileSelector.position) else {
            return nil
        }
        return MapSceneRenderSnapshot.TileSelector(
            position: tileSelector.position,
            cell: scene.world.mapGrid[tileSelector.position]
        )
    }

    private func makeTargetSelector(atTime currentTime: TimeInterval) -> MapSceneRenderSnapshot.TargetSelector? {
        guard let targetSelector = scene.targetSelector,
              let object = scene.world.objects[targetSelector.objectID],
              object.effectState != .cloak,
              let drawable = renderResources.spriteDrawables.first(where: { $0.objectID == targetSelector.objectID }) else {
            return nil
        }
        let spriteTop = drawable.layers
            .flatMap(\.vertices)
            .map(\.position.y)
            .max() ?? 0
        // The ring's lowest point sits 6 pixels above the sprite, and the gem rests 11 pixels above the ring.
        let ringCenterHeight = spriteTop + 6 + 10
        return MapSceneRenderSnapshot.TargetSelector(
            worldPosition: drawable.worldPosition,
            ringCenterHeight: ringCenterHeight,
            gemTopHeight: ringCenterHeight + 10 + 11 + 10 - targetSelector.gemDrop(atTime: currentTime)
        )
    }

    private func makeEffects(atTime currentTime: TimeInterval) -> [MapSceneRenderSnapshot.Effect] {
        let worldEffects: [MapSceneRenderSnapshot.Effect] = renderResources.worldEffectResources.map { resourceGroup in
            if resourceGroup.isExpired(atTime: currentTime) {
                resourceGroup.restart(atTime: currentTime)
            }
            return MapSceneRenderSnapshot.Effect(
                resourceGroup: resourceGroup,
                attachedWorldPosition: nil
            )
        }

        let sceneEffects: [MapSceneRenderSnapshot.Effect] = scene.world.effects.values
            .compactMap { effect -> MapSceneRenderSnapshot.Effect? in
                guard let resourceGroup = renderResources.effectResource(for: effect.id) else {
                    return nil
                }
                return MapSceneRenderSnapshot.Effect(
                    resourceGroup: resourceGroup,
                    attachedWorldPosition: effect.targetObjectID.flatMap { scene.world.objects[$0]?.worldPosition }
                )
            }
            .sorted {
                $0.resourceGroup.creationTime < $1.resourceGroup.creationTime
            }

        return worldEffects + sceneEffects
    }

    private func makeBars(atTime currentTime: TimeInterval) -> [MapSceneRenderSnapshot.Bar] {
        let hpspBars = scene.world.objects.values.compactMap { object -> MapSceneRenderSnapshot.Bar? in
            guard object.showsHPSPBar, object.effectState != .cloak else {
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
                worldPosition: object.worldPosition + [0, -0.8, 0]
            )
        }

        let castBars = scene.world.objects.values.compactMap { object -> MapSceneRenderSnapshot.Bar? in
            guard let cast = object.cast, object.effectState != .cloak else {
                return nil
            }
            let mesh = BarMesh.mesh(cast: cast, atTime: currentTime)
            return MapSceneRenderSnapshot.Bar(
                vertices: mesh.vertices,
                worldPosition: object.worldPosition
            )
        }

        return hpspBars + castBars
    }

    /// The target selector's object shows its name 2 points under its HP bar.
    /// Without a bar, the name is centered where the bar would be.
    private func makeTexts() -> [MapSceneRenderSnapshot.Text] {
        guard let targetSelector = scene.targetSelector,
              let target = scene.world.objects[targetSelector.objectID],
              target.effectState != .cloak else {
            return []
        }

        let targetNameText = TextDescriptor(name: target.name, objectType: target.type)
        let textTextures = renderResources.textTextureCache.synchronize(texts: [targetNameText])
        guard let textTexture = textTextures[targetNameText] else {
            return []
        }

        var barBottom: Float? = nil
        if target.showsHPSPBar {
            let barMesh = BarMesh.mesh(
                hp: target.hp,
                maxHp: target.maxHp,
                sp: target.sp,
                maxSp: target.maxSp,
                objectType: target.type
            )
            barBottom = barMesh.vertices.map(\.position.y).min()
        }

        let textTop = if let barBottom {
            barBottom - 2
        } else {
            targetNameText.size.y / 2
        }
        let textMesh = TextMesh(size: targetNameText.size, top: textTop)
        let text = MapSceneRenderSnapshot.Text(
            vertices: textMesh.vertices,
            worldPosition: target.worldPosition + [0, -0.8, 0],
            texture: textTexture
        )
        return [text]
    }

    private func makeCombatTexts(atTime currentTime: TimeInterval) -> [MapSceneRenderSnapshot.CombatText] {
        guard let combatTextGlyphSet = renderResources.combatTextGlyphSet else {
            return []
        }

        // A target shows one combo text at a time: the newest one that has started
        // hides the ones before it.
        let comboTexts = scene.world.combatTexts
            .filter { $0.kind.isCombo && $0.startTime <= currentTime }
            .map { ($0.target.objectID, $0) }
        let latestComboTexts = Dictionary(
            comboTexts,
            uniquingKeysWith: { $0.startTime > $1.startTime ? $0 : $1 }
        )

        return scene.world.combatTexts
            .filter { combatText in
                if combatText.kind.isCombo, let latestComboText = latestComboTexts[combatText.target.objectID] {
                    combatText === latestComboText
                } else {
                    true
                }
            }
            .compactMap { combatText in
                let anchor = scene.world.objects[combatText.target.objectID]?.worldPosition ?? combatText.target.initialWorldPosition
                guard let animation = combatText.animation(
                    atTime: currentTime,
                    anchor: anchor,
                    cameraAzimuth: scene.camera.azimuth
                ) else {
                    return nil
                }

                let mesh = CombatTextMesh(
                    for: combatText,
                    glyphSet: combatTextGlyphSet,
                    scale: animation.scale,
                    alpha: animation.alpha
                )
                guard !mesh.vertices.isEmpty else {
                    return nil
                }

                return MapSceneRenderSnapshot.CombatText(
                    vertices: mesh.vertices,
                    worldPosition: animation.worldPosition
                )
            }
    }
}
