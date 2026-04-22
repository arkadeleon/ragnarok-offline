//
//  MetalMapRenderer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/22.
//

import CoreGraphics
import Metal
import RagnarokCore
import RagnarokMetalRendering
import RagnarokRenderAssets
import RagnarokResources
import simd

final class MetalMapRenderer: Renderer {
    private static let cameraTargetOffset = SIMD3<Float>(0, 0.5, 0)
    private static let fieldOfViewDegrees: Float = 15

    struct RenderMatrices {
        var modelMatrix: simd_float4x4
        var viewMatrix: simd_float4x4
        var projectionMatrix: simd_float4x4
        var normalMatrix: simd_float3x3
        var cameraPosition: SIMD3<Float>
    }

    let device: any MTLDevice
    let resourceManager: ResourceManager

    private let skyboxRenderer: SkyboxRenderer
    private let groundRenderer: GroundRenderer
    private let waterRenderer: WaterRenderer
    private let modelRenderer: RSMModelRenderer
    private let spriteRenderer: MetalSpriteRenderer
    private let damageEffectRenderer: MetalDamageEffectRenderer
    private let tileSelectorRenderer: MetalTileSelectorRenderer

    private var skyboxResource: SkyboxRenderResource?
    private var groundResource: GroundRenderResource?
    private var waterResource: WaterRenderResource?
    private var modelResources: [RSMModelRenderResource] = []
    private var damageEffectResources: [UUID : DamageEffectRenderResource] = [:]
    private var tileSelectorResource: TileSelectorRenderResource?

    private let spriteSnapshotBuilder = SpriteSnapshotBuilder()
    private var spriteSnapshots: [GameObjectID : SpriteSnapshot] = [:]
    private(set) var spriteDrawables: [SpriteLayerDrawable] = []
    private(set) var spriteAssetStore: SpriteAssetStore?

    private var cameraState: MapCameraState = .default
    private var targetPosition: SIMD3<Float> = .zero

    private(set) var lastRenderMatrices: RenderMatrices?
    private(set) var lastViewport: CGRect = .zero

    init(resourceManager: ResourceManager) throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("MapRuntimeRenderer: Metal is not available on this device")
        }
        self.device = device
        self.resourceManager = resourceManager

        skyboxRenderer = try SkyboxRenderer(device: device)
        groundRenderer = try GroundRenderer(device: device)
        waterRenderer = try WaterRenderer(device: device)
        modelRenderer = try RSMModelRenderer(device: device)
        spriteRenderer = try MetalSpriteRenderer(device: device)
        damageEffectRenderer = try MetalDamageEffectRenderer(device: device)
        tileSelectorRenderer = try MetalTileSelectorRenderer(device: device)
    }

    func prepareRenderResources(worldAsset: WorldAsset, skyboxConfiguration: SkyboxConfiguration) async {
        skyboxResource = SkyboxRenderResource(device: device, configuration: skyboxConfiguration)

        groundResource = GroundRenderResource(device: device, asset: worldAsset.ground)
        waterResource = WaterRenderResource(device: device, asset: worldAsset.water)
        modelResources = worldAsset.models.map { modelAsset in
            RSMModelRenderResource(device: device, asset: modelAsset)
        }

        let path = ResourcePath.textureDirectory.appending(["grid.tga"])
        let image = try? await resourceManager.image(at: path)
        tileSelectorResource = TileSelectorRenderResource(device: device, image: image?.cgImage)

        let scriptContext = await resourceManager.scriptContext
        spriteAssetStore = SpriteAssetStore(device: device, resourceManager: resourceManager, scriptContext: scriptContext)
    }

    func updateCamera(cameraState: MapCameraState, targetPosition: SIMD3<Float>) {
        self.cameraState = cameraState
        self.targetPosition = targetPosition
    }

    func updateObjects(
        player: MapObjectState,
        objects: [GameObjectID : MapObjectState],
        items: [GameObjectID : MapItemState],
        scene: MapScene
    ) {
        let snapshots = spriteSnapshotBuilder.build(
            player: player,
            objects: objects,
            items: items,
            scene: scene
        )
        spriteSnapshots = snapshots
        spriteDrawables = spriteAssetStore?.sync(snapshots: snapshots) ?? []
    }

    func updateDamageEffects(_ damageEffects: [MapDamageEffect], scene: MapScene) {
        let activeEffectIDs = Set(damageEffects.map(\.id))
        damageEffectResources = damageEffectResources.filter { activeEffectIDs.contains($0.key) }

        for effect in damageEffects where damageEffectResources[effect.id] == nil {
            guard let startPosition = presentationWorldPosition(for: effect.targetObjectID)
                ?? fallbackWorldPosition(for: effect.targetObjectID, scene: scene) else {
                continue
            }

            let targetObjectType = if effect.targetObjectID == scene.state.player.id {
                scene.state.player.object.type
            } else {
                scene.state.objects[effect.targetObjectID]?.object.type
            }

            let resolvedTarget = DamageEffectRenderResource.ResolvedTarget(
                startPosition: startPosition,
                isPlayerTarget: targetObjectType == .pc
            )

            damageEffectResources[effect.id] = DamageEffectRenderResource(
                device: device,
                effect: effect,
                resolvedTarget: resolvedTarget
            )
        }
    }

    func presentationWorldPosition(for objectID: GameObjectID) -> SIMD3<Float>? {
        spriteSnapshots[objectID]?.worldPosition
    }

    func syncSelection(_ selectedPosition: SIMD2<Int>?, mapGrid: MapGrid) {
        tileSelectorResource?.syncSelection(selectedPosition, mapGrid: mapGrid)
    }

    func render(
        atTime time: CFTimeInterval,
        viewport: CGRect,
        commandBuffer: any MTLCommandBuffer,
        renderPassDescriptor: MTLRenderPassDescriptor
    ) {
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        if let depthAttachment = renderPassDescriptor.depthAttachment {
            depthAttachment.loadAction = .clear
            depthAttachment.storeAction = .dontCare
            depthAttachment.clearDepth = 1
        }

        guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        let matrices = makeRenderMatrices(viewport: viewport)
        lastRenderMatrices = matrices
        lastViewport = viewport

        if let skyboxResource {
            skyboxRenderer.render(
                resource: skyboxResource,
                renderCommandEncoder: renderCommandEncoder,
                projectionMatrix: matrices.projectionMatrix,
                viewMatrix: matrices.viewMatrix,
                cameraPosition: matrices.cameraPosition
            )
        }

        if let groundResource {
            groundRenderer.render(
                resource: groundResource,
                atTime: time,
                renderCommandEncoder: renderCommandEncoder,
                modelMatrix: matrices.modelMatrix,
                viewMatrix: matrices.viewMatrix,
                projectionMatrix: matrices.projectionMatrix,
                normalMatrix: matrices.normalMatrix
            )
        }

        if let waterResource {
            waterRenderer.render(
                resource: waterResource,
                atTime: time,
                renderCommandEncoder: renderCommandEncoder,
                modelMatrix: matrices.modelMatrix,
                viewMatrix: matrices.viewMatrix,
                projectionMatrix: matrices.projectionMatrix
            )
        }

        for modelResource in modelResources {
            modelRenderer.render(
                resource: modelResource,
                atTime: time,
                renderCommandEncoder: renderCommandEncoder,
                modelMatrix: matrices.modelMatrix,
                viewMatrix: matrices.viewMatrix,
                projectionMatrix: matrices.projectionMatrix,
                normalMatrix: matrices.normalMatrix
            )
        }

        spriteRenderer.render(
            drawables: spriteDrawables,
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            matrices: matrices
        )

        for damageEffectResource in damageEffectResources.values.sorted(by: { $0.creationTime < $1.creationTime }) {
            damageEffectRenderer.render(
                resource: damageEffectResource,
                renderCommandEncoder: renderCommandEncoder,
                matrices: matrices
            )
        }

        if let tileSelectorResource {
            tileSelectorRenderer.render(
                resource: tileSelectorResource,
                atTime: time,
                renderCommandEncoder: renderCommandEncoder,
                matrices: matrices
            )
        }

        renderCommandEncoder.endEncoding()
    }

    private func fallbackWorldPosition(for objectID: GameObjectID, scene: MapScene) -> SIMD3<Float>? {
        if let gridPosition = scene.state.object(for: objectID)?.gridPosition {
            return scene.mapGrid.worldPosition(for: gridPosition)
        } else {
            return nil
        }
    }

    private func makeRenderMatrices(viewport: CGRect) -> RenderMatrices {
        let modelMatrix = makeWorldModelMatrix()
        let worldTarget = targetPosition + Self.cameraTargetOffset

        let cameraOrientation =
            simd_quatf(angle: -cameraState.azimuth, axis: [0, 1, 0]) *
            simd_quatf(angle: -cameraState.elevation, axis: [1, 0, 0])
        let cameraPosition = worldTarget + cameraOrientation.act([0, 0, cameraState.distance])
        let cameraUp = cameraOrientation.act([0, 1, 0])

        let viewportHeight = max(Float(viewport.height), 1)
        let aspectRatio = max(Float(viewport.width) / viewportHeight, .leastNonzeroMagnitude)
        let farZ = max(cameraState.distance * 4, 1000)

        return RenderMatrices(
            modelMatrix: modelMatrix,
            viewMatrix: lookAt(cameraPosition, worldTarget, cameraUp),
            projectionMatrix: perspective(radians(Self.fieldOfViewDegrees), aspectRatio, 0.1, farZ),
            normalMatrix: simd_float3x3(modelMatrix).inverse.transpose,
            cameraPosition: cameraPosition
        )
    }

    private func makeWorldModelMatrix() -> simd_float4x4 {
        var modelMatrix = matrix_identity_float4x4
        modelMatrix = matrix_rotate(modelMatrix, radians(-180), [1, 0, 0])
        return modelMatrix
    }
}
