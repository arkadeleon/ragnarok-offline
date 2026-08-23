//
//  MapLayerRenderer.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/8/13.
//

#if os(visionOS)

import ARKit
import CompositorServices
import Metal
import QuartzCore
import RagnarokRendering
import simd

/// Drives the map scene renderer from a `LayerRenderer`, the way `MapViewController` drives
/// it from an `MTKView`.
///
/// The loop drives `MapSceneRenderer` directly; it remains on the main actor because it
/// reads and advances `MapScene`. Compositor Services would rather have a thread of
/// its own, so `waitUntilRunning()` is replaced by polling — otherwise a paused layer
/// would stall the app's windows too.
@MainActor
final class MapLayerRenderer {
    private let layerRenderer: LayerRenderer
    private let scene: MapScene
    private let renderer: MapSceneRenderer
    private let commandQueue: any MTLCommandQueue

    private let arSession = ARKitSession()
    private let worldTracking = WorldTrackingProvider()

    private let spatialInput: MapSpatialInput

    init?(layerRenderer: LayerRenderer, scene: MapScene) {
        guard let renderer = try? MapSceneRenderer(device: scene.device, configuration: .immersive),
              let commandQueue = scene.device.makeCommandQueue() else {
            return nil
        }

        self.layerRenderer = layerRenderer
        self.scene = scene
        self.renderer = renderer
        self.commandQueue = commandQueue
        self.spatialInput = MapSpatialInput(scene: scene)
    }

    func start() {
        layerRenderer.onSpatialEvent = { [spatialInput] events in
            spatialInput.handle(events)
        }

        Task { @MainActor in
            do {
                try await arSession.run([worldTracking])
            } catch {
                logger.error("MapLayerRenderer: world tracking failed to start: \(error)")
                return
            }

            await renderLoop()
        }
    }

    private func renderLoop() async {
        while true {
            switch layerRenderer.state {
            case .paused:
                try? await Task.sleep(for: .milliseconds(100))
            case .running:
                await renderFrame()
            case .invalidated:
                return
            @unknown default:
                return
            }
        }
    }

    private func renderFrame() async {
        guard let frame = layerRenderer.queryNextFrame() else {
            return
        }

        frame.startUpdate()
        let renderScene = scene.makeRenderScene(atTime: CACurrentMediaTime())
        frame.endUpdate()

        guard let timing = frame.predictTiming() else {
            return
        }
        try? await LayerRenderer.Clock().sleep(until: timing.optimalInputTime, tolerance: nil)

        frame.startSubmission()
        defer {
            frame.endSubmission()
        }

        guard let drawable = frame.queryDrawable(),
              let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }

        let anchorTime = LayerRenderer.Clock.Instant.epoch.duration(to: timing.trackableAnchorTime)
        drawable.deviceAnchor = worldTracking.queryDeviceAnchor(atTimestamp: anchorTime.timeInterval)

        // The eye cannot move, so the game camera places the map around the viewer.
        // RenderCamera and the compositor both use right-handed view space with visible
        // geometry at -Z, so each eye pose can compose the placement directly.
        let worldPlacement = scene.makeCamera(viewport: drawable.views[0].textureMap.viewport).viewMatrix

        spatialInput.update(
            worldPlacement: worldPlacement,
            originFromDevice: drawable.deviceAnchor?.originFromAnchorTransform ?? matrix_identity_float4x4
        )

        let views = drawable.views.indices.map { index in
            RenderView(
                viewport: drawable.views[index].textureMap.viewport,
                camera: makeCamera(drawable: drawable, viewIndex: index, worldPlacement: worldPlacement)
            )
        }
        scene.lastCamera = views.last?.camera

        renderer.render(
            frame: RenderFrame(
                time: CACurrentMediaTime(),
                commandBuffer: commandBuffer,
                renderPassDescriptor: makeRenderPassDescriptor(drawable: drawable),
                views: views
            ),
            scene: renderScene
        )

        drawable.encodePresent(commandBuffer: commandBuffer)
        commandBuffer.commit()
    }

    /// The camera for one eye, looking at the map wherever `worldPlacement` put it.
    ///
    /// The placement rides on the view matrix rather than the model matrix, so the world
    /// keeps its own frame: normals still match the map's light, and sprites still
    /// billboard against the map's axes.
    ///
    /// The angles come from the game camera, not from the eye: effects that turn to face
    /// the viewer turn with the map's placement, the way they do on iOS and macOS.
    private func makeCamera(
        drawable: LayerRenderer.Drawable,
        viewIndex: Int,
        worldPlacement: simd_float4x4
    ) -> RenderCamera {
        let originFromDevice = drawable.deviceAnchor?.originFromAnchorTransform ?? matrix_identity_float4x4
        let originFromEye = originFromDevice * drawable.views[viewIndex].transform

        return RenderCamera(
            viewMatrix: originFromEye.inverse * worldPlacement,
            projectionMatrix: drawable.computeProjection(convention: .rightUpBack, viewIndex: viewIndex),
            position: (worldPlacement.inverse * originFromEye.columns.3).xyz,
            azimuth: scene.cameraState.azimuth,
            elevation: scene.cameraState.elevation
        )
    }

    private func makeRenderPassDescriptor(drawable: LayerRenderer.Drawable) -> MTLRenderPassDescriptor {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.colorTextures[0]
        renderPassDescriptor.depthAttachment.texture = drawable.depthTextures[0]
        renderPassDescriptor.rasterizationRateMap = drawable.rasterizationRateMaps.first
        return renderPassDescriptor
    }
}

extension simd_float4 {
    var xyz: SIMD3<Float> {
        SIMD3<Float>(x, y, z)
    }
}

#endif
