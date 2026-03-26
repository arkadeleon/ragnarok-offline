//
//  MapRuntimeRenderer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/22.
//

import CoreGraphics
import Metal
import RagnarokRenderers
import RagnarokResources
import RagnarokSceneAssets
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
    }

    let device: any MTLDevice

    private var groundRenderer: MapGroundRendererAdapter?
    private var waterRenderer: MapWaterRendererAdapter?
    private var modelRenderer: MapModelRendererAdapter?
    private(set) var spriteBillboardRenderer: SpriteBillboardRenderer?
    private var selectionOverlayRenderer: MetalSelectionOverlayRenderer?

    private let spriteBillboardSnapshotEvaluator = SpriteBillboardSnapshotEvaluator()
    private var spriteBillboardSnapshots: [GameObjectID : SpriteBillboardSnapshot] = [:]
    private var spriteBillboardAssetStore: SpriteBillboardAssetStore?

    private var cameraState: MapCameraState = .default
    private var targetPosition: SIMD3<Float> = .zero

    private(set) var lastRenderMatrices: RenderMatrices?
    private(set) var lastViewport: CGRect = .zero

    init() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("MapRuntimeRenderer: Metal is not available on this device")
        }
        self.device = device
    }

    func setWorldAsset(_ worldAsset: MapWorldAsset?) {
        guard let worldAsset else {
            groundRenderer = nil
            waterRenderer = nil
            modelRenderer = nil
            spriteBillboardAssetStore?.cancelAllTasks()
            spriteBillboardAssetStore = nil
            spriteBillboardRenderer?.reset()
            spriteBillboardRenderer = nil
            selectionOverlayRenderer = nil
            spriteBillboardSnapshots.removeAll()
            return
        }

        groundRenderer = try? MapGroundRendererAdapter(
            device: device,
            asset: worldAsset.ground,
            lighting: worldAsset.lighting
        )
        waterRenderer = try? MapWaterRendererAdapter(
            device: device,
            asset: worldAsset.water,
            lighting: worldAsset.lighting
        )
        modelRenderer = try? MapModelRendererAdapter(
            device: device,
            assets: worldAsset.models,
            lighting: worldAsset.lighting
        )
        spriteBillboardRenderer = try? SpriteBillboardRenderer(device: device)
        spriteBillboardAssetStore = SpriteBillboardAssetStore(device: device)
        selectionOverlayRenderer = MetalSelectionOverlayRenderer()
    }

    func prepareDynamicRenderers(resourceManager: ResourceManager) async {
        await selectionOverlayRenderer?.prepare(device: device, resourceManager: resourceManager)
    }

    func updateCamera(cameraState: MapCameraState, targetPosition: SIMD3<Float>) {
        self.cameraState = cameraState
        self.targetPosition = targetPosition
    }

    func updateObjects(
        player: MapObjectState,
        objects: [GameObjectID : MapObjectState],
        items: [GameObjectID : MapItemState],
        scene: MapScene,
        resourceManager: ResourceManager
    ) {
        let snapshots = spriteBillboardSnapshotEvaluator.evaluate(
            player: player,
            objects: objects,
            items: items,
            scene: scene
        )
        spriteBillboardSnapshots = snapshots
        spriteBillboardAssetStore?.sync(
            snapshots: snapshots,
            resourceManager: resourceManager
        )
        let drawables = spriteBillboardAssetStore?.drawables(for: snapshots) ?? [:]
        spriteBillboardRenderer?.update(drawables: drawables)
    }

    func presentationWorldPosition(for objectID: GameObjectID) -> SIMD3<Float>? {
        spriteBillboardSnapshots[objectID]?.worldPosition
    }

    func syncSelection(_ selectedPosition: SIMD2<Int>?, mapGrid: MapGrid) {
        selectionOverlayRenderer?.syncSelection(selectedPosition, mapGrid: mapGrid)
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

        groundRenderer?.render(
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            matrices: matrices
        )
        waterRenderer?.render(
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            matrices: matrices
        )
        modelRenderer?.render(
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            matrices: matrices
        )
        spriteBillboardRenderer?.render(
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

        renderCommandEncoder.endEncoding()
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
            normalMatrix: simd_float3x3(modelMatrix).inverse.transpose
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
