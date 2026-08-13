//
//  MetalMapRenderer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/22.
//

import CoreGraphics
import Foundation
import Metal
import RagnarokCore
import RagnarokRendering
import simd

final class MetalMapRenderer: Renderer {
    private static let cameraTargetOffset = SIMD3<Float>(0, 0.5, 0)
    private static let fieldOfViewDegrees: Float = 15

    let device: any MTLDevice
    let configuration: RenderConfiguration

    private let skyboxRenderer: SkyboxRenderer
    private let worldRenderer: WorldRenderer
    private let spriteRenderer: MetalSpriteRenderer
    private let combatTextRenderer: MetalCombatTextRenderer
    private let gaugeRenderer: GaugeRenderer
    private let effectRenderer: EffectRenderer
    private let tileSelectorRenderer: MetalTileSelectorRenderer

    var skyboxResource: SkyboxRenderResource?
    var worldResource: WorldRenderResource?
    var spriteDrawables: [SpriteLayerDrawable] = []
    var combatTextRenderResources: [CombatTextRenderResource] = []
    var gauges: [Gauge] = []
    var objects: [GameObjectID : MetalMapObject] = [:]
    var effects: [MetalMapEffect] = []
    var tileSelectorResource: TileSelectorRenderResource?

    private var cameraState = MapCameraState()
    private var targetPosition: SIMD3<Float> = .zero

    private(set) var lastCamera: RenderCamera?

    init(configuration: RenderConfiguration) throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("MapRuntimeRenderer: Metal is not available on this device")
        }
        self.device = device
        self.configuration = configuration

        skyboxRenderer = try SkyboxRenderer(device: device, configuration: configuration)
        worldRenderer = try WorldRenderer(device: device, configuration: configuration)
        spriteRenderer = try MetalSpriteRenderer(device: device, configuration: configuration)
        combatTextRenderer = try MetalCombatTextRenderer(device: device, configuration: configuration)
        gaugeRenderer = try GaugeRenderer(device: device, configuration: configuration)
        effectRenderer = try EffectRenderer(device: device, configuration: configuration)
        tileSelectorRenderer = try MetalTileSelectorRenderer(device: device, configuration: configuration)
    }

    func renderPosition(for worldPosition: SIMD3<Float>) -> SIMD3<Float> {
        [
            worldPosition.x,
            worldPosition.z,
            -worldPosition.y,
        ]
    }

    func updateCamera(cameraState: MapCameraState, targetPosition: SIMD3<Float>) {
        self.cameraState = cameraState
        self.targetPosition = targetPosition
    }

    func makeCamera(atTime time: TimeInterval, viewport: MTLViewport) -> RenderCamera {
        let worldTarget = renderPosition(for: targetPosition) + Self.cameraTargetOffset

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
            projectionMatrix: perspective(radians(Self.fieldOfViewDegrees), aspectRatio, 0.1, farZ),
            position: cameraPosition,
            azimuth: cameraState.azimuth,
            elevation: cameraState.elevation
        )
    }

    func render(frame: RenderFrame) {
        let renderPassDescriptor = frame.renderPassDescriptor
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.depthAttachment.loadAction = .clear
        renderPassDescriptor.depthAttachment.storeAction = .dontCare
        renderPassDescriptor.depthAttachment.clearDepth = configuration.clearDepth

        guard let renderCommandEncoder = frame.commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        for view in frame.views {
            renderCommandEncoder.setViewport(view.viewport)

            var camera = view.camera
            camera.azimuth = cameraState.azimuth
            camera.elevation = cameraState.elevation
            lastCamera = camera

            renderContents(
                atTime: frame.time,
                viewport: view.viewport,
                modelMatrix: makeWorldModelMatrix(),
                camera: camera,
                renderCommandEncoder: renderCommandEncoder
            )
        }

        renderCommandEncoder.endEncoding()
    }

    private func renderContents(
        atTime time: TimeInterval,
        viewport: MTLViewport,
        modelMatrix: simd_float4x4,
        camera: RenderCamera,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        if let skyboxResource {
            skyboxRenderer.render(
                resource: skyboxResource,
                camera: camera,
                renderCommandEncoder: renderCommandEncoder
            )
        }

        if let worldResource {
            worldRenderer.renderGroundAndModels(
                resource: worldResource,
                atTime: time,
                modelMatrix: modelMatrix,
                camera: camera,
                renderCommandEncoder: renderCommandEncoder
            )
        }

        if let worldResource {
            worldRenderer.renderEffects(
                resource: worldResource,
                atTime: time,
                beforeEntities: true,
                modelMatrix: modelMatrix,
                camera: camera,
                renderCommandEncoder: renderCommandEncoder
            )
        }

        renderEffects(
            effects.filter { $0.renderResourceGroup?.rendersBeforeEntities == true },
            atTime: time,
            modelMatrix: modelMatrix,
            camera: camera,
            renderCommandEncoder: renderCommandEncoder
        )

        spriteRenderer.render(
            drawables: spriteDrawables,
            viewport: viewport,
            modelMatrix: modelMatrix,
            camera: camera,
            renderCommandEncoder: renderCommandEncoder
        )

        // Water renders after sprites so submerged
        // sprites blend through the translucent surface.
        if let worldResource {
            worldRenderer.renderWater(
                resource: worldResource,
                atTime: time,
                modelMatrix: modelMatrix,
                camera: camera,
                renderCommandEncoder: renderCommandEncoder
            )
        }

        if let worldResource {
            worldRenderer.renderEffects(
                resource: worldResource,
                atTime: time,
                beforeEntities: false,
                modelMatrix: modelMatrix,
                camera: camera,
                renderCommandEncoder: renderCommandEncoder
            )
        }

        renderEffects(
            effects.filter { $0.renderResourceGroup?.rendersBeforeEntities == false },
            atTime: time,
            modelMatrix: modelMatrix,
            camera: camera,
            renderCommandEncoder: renderCommandEncoder
        )

        if let tileSelectorResource {
            tileSelectorRenderer.render(
                resource: tileSelectorResource,
                atTime: time,
                modelMatrix: modelMatrix,
                camera: camera,
                renderCommandEncoder: renderCommandEncoder
            )
        }

        gaugeRenderer.render(
            gauges: gauges,
            modelMatrix: modelMatrix,
            camera: camera,
            renderCommandEncoder: renderCommandEncoder
        )

        // Combat text renders last so nothing draws over it.
        combatTextRenderer.render(
            resources: combatTextRenderResources,
            modelMatrix: modelMatrix,
            camera: camera,
            renderCommandEncoder: renderCommandEncoder
        )
    }

    private func renderEffects(
        _ effects: [MetalMapEffect],
        atTime time: TimeInterval,
        modelMatrix: simd_float4x4,
        camera: RenderCamera,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        let sortedEffects = effects.sorted {
            guard let lhsCreationTime = $0.renderResourceGroup?.creationTime else {
                return false
            }
            guard let rhsCreationTime = $1.renderResourceGroup?.creationTime else {
                return true
            }
            return lhsCreationTime < rhsCreationTime
        }

        for effect in sortedEffects {
            guard let resourceGroup = effect.renderResourceGroup else {
                continue
            }

            let targetObject = effect.targetObjectID.flatMap { objects[$0] }

            effectRenderer.render(
                resourceGroup: resourceGroup,
                atTime: time,
                attachedWorldPosition: targetObject?.worldPosition,
                modelMatrix: modelMatrix,
                camera: camera,
                renderCommandEncoder: renderCommandEncoder
            )
        }
    }

    private func makeWorldModelMatrix() -> simd_float4x4 {
        var modelMatrix = matrix_identity_float4x4
        modelMatrix = matrix_rotate(modelMatrix, radians(-180), [1, 0, 0])
        return modelMatrix
    }
}
