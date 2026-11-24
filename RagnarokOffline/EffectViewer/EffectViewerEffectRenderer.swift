//
//  EffectViewerEffectRenderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/6/29.
//

import CoreGraphics
import Foundation
import Metal
import QuartzCore
import RagnarokCore
import RagnarokEffects
import RagnarokFileFormats
import RagnarokRenderAssets
import RagnarokRendering
import RagnarokResources
import simd

@MainActor
class EffectViewerEffectRenderer: Renderer {
    private enum RenderPayload {
        case legacy(EffectRenderer.RenderPayload)
        case str(STREffectRenderer.RenderPayload)
        case primitive(EffectPrimitiveBatchRenderer.RenderPayload)
    }

    private enum Backend {
        case legacy(renderer: EffectRenderer, resourceGroup: EffectRenderResourceGroup)
        case managed(
            manager: EffectManager,
            world: EffectViewerEffectWorldContext,
            strRenderer: STREffectRenderer,
            primitiveRenderer: EffectPrimitiveBatchRenderer
        )
    }

    let device: any MTLDevice
    let configuration: RenderConfiguration

    private let renderQueue = RenderQueue<RenderPayload>()
    private let backend: Backend
    private let fog = Fog()

    let camera: OrbitalCamera

    init(device: any MTLDevice, configuration: RenderConfiguration, assetGroup: EffectAssetGroup) throws {
        self.device = device
        self.configuration = configuration

        let effectRenderer = try EffectRenderer(device: device, configuration: configuration)
        let resourceGroup = EffectRenderResourceGroup(
            device: device,
            assetGroup: assetGroup,
            creationTime: CACurrentMediaTime(),
            delay: 0
        )
        self.backend = .legacy(renderer: effectRenderer, resourceGroup: resourceGroup)
        self.camera = Self.makeDefaultCamera()
    }

    init(
        device: any MTLDevice,
        configuration: RenderConfiguration,
        effectID: EffectID,
        resourceManager: ResourceManager,
        ez2strEffectCatalog: EZ2STREffectCatalog? = nil
    ) throws {
        self.device = device
        self.configuration = configuration

        let assetStore = EffectAssetStore(device: device, resourceManager: resourceManager)
        let manager = EffectManager(assetStore: assetStore, ez2strEffectCatalog: ez2strEffectCatalog)
        let world = EffectViewerEffectWorldContext()
        let strRenderer = try STREffectRenderer(device: device, configuration: configuration)
        let primitiveRenderer = try EffectPrimitiveBatchRenderer(device: device, configuration: configuration)

        let request = EffectSpawnRequest(
            effectID: effectID,
            worldPosition: .zero,
            sourceWorldPosition: SIMD3<Float>(-5, 0, -5),
            ownerObjectID: EffectViewerEffectWorldContext.targetObjectID,
            targetObjectID: EffectViewerEffectWorldContext.targetObjectID,
            sourceObjectID: EffectViewerEffectWorldContext.sourceObjectID
        )
        manager.spawn(request)

        self.backend = .managed(
            manager: manager,
            world: world,
            strRenderer: strRenderer,
            primitiveRenderer: primitiveRenderer
        )
        self.camera = Self.makeDefaultCamera()
    }

    private static func makeDefaultCamera() -> OrbitalCamera {
        let camera = OrbitalCamera(distance: 20)
        camera.fovy = 45
        camera.nearZ = 1
        camera.farZ = 1000
        camera.elevation = radians(20)
        camera.minimumDistance = 8
        camera.maximumDistance = 80
        camera.target = [0, 1.5, 0]
        return camera
    }

    func makeCamera(atTime time: TimeInterval, viewport: MTLViewport) -> RenderCamera {
        camera.update(atTime: time)
        camera.update(size: viewport.size)

        if case .managed(_, let world, _, _) = backend {
            let inverseView = camera.viewMatrix.inverse
            world.cameraWorldPosition = [
                inverseView.columns.3.x,
                inverseView.columns.3.y,
                inverseView.columns.3.z,
            ]
            world.cameraYawDegrees = degrees(camera.azimuth)
        }

        return RenderCamera(
            viewMatrix: camera.viewMatrix,
            projectionMatrix: camera.projectionMatrix,
            azimuth: camera.azimuth,
            elevation: camera.elevation
        )
    }

    func render(frame: RenderFrame) {
        let renderPassDescriptor = frame.renderPassDescriptor
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.depthAttachment.clearDepth = configuration.clearDepth

        guard let renderCommandEncoder = frame.commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        renderQueue.removeAll()

        switch backend {
        case .legacy(let effectRenderer, let resourceGroup):
            effectRenderer.submit(
                resourceGroup: resourceGroup,
                atTime: frame.time,
                fog: fog,
                modelMatrix: matrix_identity_float4x4,
                into: renderQueue,
                transform: RenderPayload.legacy
            )
        case .managed(let manager, let world, let strRenderer, let primitiveRenderer):
            manager.update(atTime: frame.time, world: world)
            for payload in manager.collectSTRPayloads(fog: fog, world: world) {
                strRenderer.submit(
                    payload: payload,
                    into: renderQueue,
                    transformPayload: RenderPayload.str
                )
            }
            for payload in manager.collectPrimitivePayloads(fog: fog, world: world) {
                primitiveRenderer.submit(
                    payload: payload,
                    into: renderQueue,
                    transformPayload: RenderPayload.primitive
                )
            }
        }

        for view in frame.views {
            renderCommandEncoder.setViewport(view.viewport)

            renderQueue.sort(camera: view.camera)

            for bucket in RenderPassBucket.allCases {
                for item in renderQueue.items(in: bucket) {
                    switch (item.payload, backend) {
                    case (.legacy(let payload), .legacy(let effectRenderer, _)):
                        effectRenderer.render(
                            payload: payload,
                            camera: view.camera,
                            renderCommandEncoder: renderCommandEncoder
                        )
                    case (.str(let payload), .managed(_, _, let strRenderer, _)):
                        strRenderer.render(
                            payload: payload,
                            camera: view.camera,
                            renderCommandEncoder: renderCommandEncoder
                        )
                    case (.primitive(let payload), .managed(_, _, _, let primitiveRenderer)):
                        primitiveRenderer.render(
                            payload: payload,
                            camera: view.camera,
                            renderCommandEncoder: renderCommandEncoder
                        )
                    default:
                        break
                    }
                }
            }
        }

        renderCommandEncoder.endEncoding()
    }

    func isComplete(atTime time: TimeInterval) -> Bool {
        switch backend {
        case .legacy(_, let resourceGroup):
            resourceGroup.isExpired(atTime: time)
        case .managed(let manager, _, _, _):
            !manager.hasEffects
        }
    }
}
