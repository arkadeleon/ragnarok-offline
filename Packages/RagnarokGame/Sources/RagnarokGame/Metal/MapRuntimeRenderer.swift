//
//  MapRuntimeRenderer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/22.
//

import CoreGraphics
import Metal
import RagnarokMetalRendering
import RagnarokRenderAssets
import RagnarokResources
import SGLMath
import simd

final class MapRuntimeRenderer: Renderer {
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

    private var skyboxRenderer: MetalSkyboxRenderer?
    private var groundRenderer: GroundRenderer?
    private var waterRenderer: WaterRenderer?
    private var modelRenderer: ModelRenderer?
    private(set) var spriteRenderer: MetalSpriteRenderer?
    private var selectionOverlayRenderer: MetalSelectionOverlayRenderer?
    private var damageEffectRenderer: MetalDamageEffectRenderer?

    private let spriteSnapshotEvaluator = SpriteSnapshotEvaluator()
    private var spriteSnapshots: [GameObjectID : SpriteSnapshot] = [:]
    private var spriteAssetStore: SpriteAssetStore?

    private var cameraState: MapCameraState = .default
    private var targetPosition: SIMD3<Float> = .zero

    private(set) var lastRenderMatrices: RenderMatrices?
    private(set) var lastViewport: CGRect = .zero

    init(resourceManager: ResourceManager) {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("MapRuntimeRenderer: Metal is not available on this device")
        }
        self.device = device
        self.resourceManager = resourceManager
        self.damageEffectRenderer = try? MetalDamageEffectRenderer(device: device)
    }

    func setWorldAsset(_ worldAsset: WorldAsset?) {
        guard let worldAsset else {
            skyboxRenderer = nil
            groundRenderer = nil
            waterRenderer = nil
            modelRenderer = nil
            spriteAssetStore?.cancelAllTasks()
            spriteAssetStore = nil
            spriteRenderer?.reset()
            spriteRenderer = nil
            selectionOverlayRenderer = nil
            damageEffectRenderer?.reset()
            spriteSnapshots.removeAll()
            return
        }

        let groundAdapter = GroundRenderAssetAdapter(
            device: device,
            asset: worldAsset.ground
        )
        groundRenderer = try? GroundRenderer(
            device: device,
            ground: groundAdapter.asset.ground,
            baseColorTexture: groundAdapter.baseColorTexture,
            lightmapTexture: groundAdapter.lightmapTexture,
            tileColorTexture: groundAdapter.tileColorTexture,
            lighting: worldAsset.lighting
        )

        let waterAdapter = WaterRenderAssetAdapter(device: device, asset: worldAsset.water)
        let waterTextures = waterAdapter.texture.map { [$0] } ?? []
        waterRenderer = try? WaterRenderer(
            device: device,
            water: waterAdapter.asset.water,
            textures: waterTextures,
            lighting: worldAsset.lighting
        )

        let modelAdapter = RSMModelRenderAssetAdapter(device: device, assets: worldAsset.models)
        modelRenderer = try? ModelRenderer(
            device: device,
            models: modelAdapter.models,
            textures: modelAdapter.textures,
            lighting: worldAsset.lighting
        )

        spriteRenderer = try? MetalSpriteRenderer(device: device)
        spriteAssetStore = SpriteAssetStore(device: device, resourceManager: resourceManager)
        selectionOverlayRenderer = nil
    }

    func prepareDynamicRenderers() async {
        let path = ResourcePath.textureDirectory.appending(["grid.tga"])
        guard let image = try? await resourceManager.image(at: path),
              let selectionTexture = MetalTextureFactory.makeTexture(
                from: image.cgImage,
                device: device,
                label: "tile-selector"
              ) else {
            selectionOverlayRenderer = nil
            return
        }

        selectionOverlayRenderer = try? MetalSelectionOverlayRenderer(
            device: device,
            selectionTexture: selectionTexture
        )
    }

    func setSkyboxConfiguration(_ configuration: SkyboxConfiguration) {
        if skyboxRenderer == nil {
            skyboxRenderer = try? MetalSkyboxRenderer(device: device)
        }
        skyboxRenderer?.configure(with: configuration)
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
        let snapshots = spriteSnapshotEvaluator.evaluate(
            player: player,
            objects: objects,
            items: items,
            scene: scene
        )
        spriteSnapshots = snapshots
        spriteAssetStore?.sync(snapshots: snapshots)
        let drawables = spriteAssetStore?.drawables(for: snapshots) ?? [:]
        spriteRenderer?.update(drawables: drawables)
    }

    func presentationWorldPosition(for objectID: GameObjectID) -> SIMD3<Float>? {
        spriteSnapshots[objectID]?.worldPosition
    }

    func syncSelection(_ selectedPosition: SIMD2<Int>?, mapGrid: MapGrid) {
        selectionOverlayRenderer?.syncSelection(selectedPosition, mapGrid: mapGrid)
    }

    func updateDamageEffects(_ damageEffects: [MapDamageEffect], scene: MapScene) {
        damageEffectRenderer?.sync(with: damageEffects) { [weak self] effect in
            guard let self else {
                return nil
            }

            guard let startPosition = self.presentationWorldPosition(for: effect.targetObjectID)
                ?? self.fallbackWorldPosition(for: effect.targetObjectID, scene: scene) else {
                return nil
            }

            let targetObjectType = if effect.targetObjectID == scene.state.player.id {
                scene.state.player.object.type
            } else {
                scene.state.objects[effect.targetObjectID]?.object.type
            }

            return MetalDamageEffectRenderer.ResolvedTarget(
                startPosition: startPosition,
                isPlayerTarget: targetObjectType == .pc
            )
        }
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

        skyboxRenderer?.render(
            renderCommandEncoder: renderCommandEncoder,
            projectionMatrix: matrices.projectionMatrix,
            viewMatrix: matrices.viewMatrix,
            cameraPosition: matrices.cameraPosition
        )
        groundRenderer?.render(
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            modelMatrix: matrices.modelMatrix,
            viewMatrix: matrices.viewMatrix,
            projectionMatrix: matrices.projectionMatrix,
            normalMatrix: matrices.normalMatrix
        )
        waterRenderer?.render(
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            modelMatrix: matrices.modelMatrix,
            viewMatrix: matrices.viewMatrix,
            projectionMatrix: matrices.projectionMatrix
        )
        modelRenderer?.render(
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            modelMatrix: matrices.modelMatrix,
            viewMatrix: matrices.viewMatrix,
            projectionMatrix: matrices.projectionMatrix,
            normalMatrix: matrices.normalMatrix
        )
        spriteRenderer?.render(
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            matrices: matrices,
            viewport: viewport
        )
        selectionOverlayRenderer?.render(
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            matrices: matrices
        )
        damageEffectRenderer?.render(
            renderCommandEncoder: renderCommandEncoder,
            matrices: matrices
        )

        renderCommandEncoder.endEncoding()
    }

    private func fallbackWorldPosition(for objectID: GameObjectID, scene: MapScene) -> SIMD3<Float>? {
        if objectID == scene.state.player.id {
            return scene.position(for: scene.state.player.gridPosition)
        }

        guard let objectState = scene.state.objects[objectID] else {
            return nil
        }

        return scene.position(for: objectState.gridPosition)
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
        guard groundRenderer != nil else {
            return matrix_identity_float4x4
        }

        var modelMatrix = matrix_identity_float4x4
        modelMatrix = matrix_rotate(modelMatrix, radians(-180), [1, 0, 0])
        return modelMatrix
    }
}
