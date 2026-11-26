//
//  EffectViewerEffectRenderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/6/29.
//

import CoreGraphics
import Foundation
import Metal
import Observation
import QuartzCore
import RagnarokCore
import RagnarokEffects
import RagnarokRenderAssets
import RagnarokRendering
import RagnarokResources
import simd

enum EffectViewerPlaybackRate: Double, CaseIterable, Identifiable {
    case tenth = 0.1
    case quarter = 0.25
    case half = 0.5
    case normal = 1.0

    var id: Double {
        rawValue
    }

    var label: String {
        switch self {
        case .tenth: "0.1×"
        case .quarter: "0.25×"
        case .half: "0.5×"
        case .normal: "1×"
        }
    }
}

@MainActor
@Observable
final class EffectViewerEffectRenderer: Renderer {
    private enum RenderPayload {
        case str(STREffectRenderer.RenderPayload)
        case primitive(EffectPrimitiveBatchRenderer.RenderPayload)
    }

    private struct CachedTick {
        let strPayloads: [STREffectRenderer.RenderPayload]
        let primitivePayloads: [EffectPrimitiveBatchRenderer.RenderPayload]
    }

    private static let maxHistoryTicks = 1800
    private static let maxSeekAdvanceTicks = 600

    let device: any MTLDevice
    let configuration: RenderConfiguration
    let camera: OrbitalCamera

    var isPlaying = true
    private(set) var isCompleted = false
    var isLooping = true
    var playbackRate: EffectViewerPlaybackRate = .normal

    private(set) var currentTick: Int = 0
    private(set) var historyBaseTick: Int = 0
    private(set) var simulatedTickCount: Int = 0
    private(set) var estimatedTotalTicks: Int?
    private(set) var actualTotalTicks: Int?

    var minTick: Int {
        historyBaseTick
    }

    var maxTick: Int {
        if let actualTotalTicks {
            return max(historyBaseTick, actualTotalTicks - 1)
        }
        let simulatedMaxTick = historyBaseTick + max(0, simulatedTickCount - 1)
        if let estimatedTotalTicks {
            return max(simulatedMaxTick, estimatedTotalTicks - 1)
        }
        return max(historyBaseTick, simulatedMaxTick)
    }

    var totalTicks: Int? {
        actualTotalTicks ?? estimatedTotalTicks
    }

    var canStepBackward: Bool {
        currentTick > historyBaseTick
    }

    var canStepForward: Bool {
        currentTick < historyBaseTick + simulatedTickCount - 1 || manager.hasEffects
    }

    @ObservationIgnored private let effectID: EffectID
    @ObservationIgnored private let renderQueue = RenderQueue<RenderPayload>()
    @ObservationIgnored private let stageRenderer: EffectViewerStageRenderer
    @ObservationIgnored private let manager: EffectManager
    @ObservationIgnored private let world: EffectViewerEffectWorldContext
    @ObservationIgnored private let strRenderer: STREffectRenderer
    @ObservationIgnored private let primitiveRenderer: EffectPrimitiveBatchRenderer
    @ObservationIgnored private let fog = Fog()

    @ObservationIgnored private var tickHistory: [CachedTick] = []
    @ObservationIgnored private var lastRenderTime: TimeInterval?
    @ObservationIgnored private var tickAccumulator: TimeInterval = 0

    init(
        device: any MTLDevice,
        configuration: RenderConfiguration,
        effectID: EffectID,
        resourceManager: ResourceManager,
        ez2strEffectCatalog: EZ2STREffectCatalog? = nil
    ) throws {
        self.device = device
        self.configuration = configuration
        self.effectID = effectID

        let assetStore = EffectAssetStore(device: device, resourceManager: resourceManager)
        self.manager = EffectManager(assetStore: assetStore, ez2strEffectCatalog: ez2strEffectCatalog)
        self.world = EffectViewerEffectWorldContext()
        self.stageRenderer = try EffectViewerStageRenderer(device: device, configuration: configuration)
        self.strRenderer = try STREffectRenderer(device: device, configuration: configuration)
        self.primitiveRenderer = try EffectPrimitiveBatchRenderer(device: device, configuration: configuration)
        self.camera = Self.makeDefaultCamera()

        let lifetime = effectID.defaultLifetimeTicks
        self.estimatedTotalTicks = (1..<999).contains(lifetime) ? lifetime : nil

        spawnEffect()
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

        let inverseView = camera.viewMatrix.inverse
        world.cameraWorldPosition = [
            inverseView.columns.3.x,
            inverseView.columns.3.y,
            inverseView.columns.3.z,
        ]
        world.cameraYawDegrees = degrees(camera.azimuth)
        world.cameraPitchDegrees = degrees(camera.elevation)

        return RenderCamera(
            viewMatrix: camera.viewMatrix,
            projectionMatrix: camera.projectionMatrix,
            azimuth: camera.azimuth,
            elevation: camera.elevation
        )
    }

    func togglePlayPause() {
        if isPlaying {
            pause()
        } else if isCompleted {
            replay()
        } else {
            isPlaying = true
            lastRenderTime = nil
        }
    }

    func pause() {
        isPlaying = false
        lastRenderTime = nil
    }

    func replay() {
        manager.removeAll()
        tickHistory.removeAll(keepingCapacity: true)
        historyBaseTick = 0
        simulatedTickCount = 0
        currentTick = 0
        isCompleted = false
        tickAccumulator = 0
        lastRenderTime = nil
        isPlaying = true
        spawnEffect()
    }

    func stepBackwardTick() {
        pause()
        if currentTick > historyBaseTick {
            currentTick -= 1
            isCompleted = false
        }
    }

    func stepForwardTick() {
        pause()
        let nextTick = currentTick + 1
        if nextTick < historyBaseTick + tickHistory.count {
            currentTick = nextTick
            isCompleted = !manager.hasEffects && nextTick == historyBaseTick + tickHistory.count - 1
        } else if manager.hasEffects {
            simulateNextTick()
            currentTick = max(historyBaseTick, historyBaseTick + tickHistory.count - 1)
            isCompleted = !manager.hasEffects
        }
    }

    func seek(toTick targetTick: Int) {
        pause()
        let clampedTarget = max(historyBaseTick, targetTick)
        let latestCachedTick = historyBaseTick + tickHistory.count - 1

        if clampedTarget <= latestCachedTick {
            currentTick = clampedTarget
            isCompleted = !manager.hasEffects && clampedTarget == latestCachedTick
            return
        }

        var advanced = 0
        while historyBaseTick + tickHistory.count - 1 < clampedTarget && manager.hasEffects && advanced < Self.maxSeekAdvanceTicks {
            simulateNextTick()
            advanced += 1
        }

        let newLatestTick = max(historyBaseTick, historyBaseTick + tickHistory.count - 1)
        currentTick = min(clampedTarget, newLatestTick)
        isCompleted = !manager.hasEffects && currentTick == newLatestTick
    }

    func toggleLooping() {
        isLooping.toggle()
    }

    func render(frame: RenderFrame) {
        advancePlayback(atTime: frame.time)

        let renderPassDescriptor = frame.renderPassDescriptor
        let edgeColor = EffectViewerStageRenderer.edgeCharcoalColor
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
            red: Double(edgeColor.x),
            green: Double(edgeColor.y),
            blue: Double(edgeColor.z),
            alpha: 1
        )
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.depthAttachment.clearDepth = configuration.clearDepth

        guard let renderCommandEncoder = frame.commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        renderQueue.removeAll()

        let historyIndex = currentTick - historyBaseTick
        if tickHistory.indices.contains(historyIndex) {
            let cachedTick = tickHistory[historyIndex]
            for payload in cachedTick.strPayloads {
                strRenderer.submit(
                    payload: payload,
                    into: renderQueue,
                    transformPayload: RenderPayload.str
                )
            }
            for payload in cachedTick.primitivePayloads {
                primitiveRenderer.submit(
                    payload: payload,
                    into: renderQueue,
                    transformPayload: RenderPayload.primitive
                )
            }
        }

        for view in frame.views {
            renderCommandEncoder.setViewport(view.viewport)

            stageRenderer.renderBackdrop(renderCommandEncoder: renderCommandEncoder)
            stageRenderer.renderGroundGrid(camera: view.camera, renderCommandEncoder: renderCommandEncoder)

            renderQueue.sort(camera: view.camera)

            for bucket in RenderPassBucket.allCases {
                for item in renderQueue.items(in: bucket) {
                    switch item.payload {
                    case .str(let payload):
                        strRenderer.render(
                            payload: payload,
                            camera: view.camera,
                            renderCommandEncoder: renderCommandEncoder
                        )
                    case .primitive(let payload):
                        primitiveRenderer.render(
                            payload: payload,
                            camera: view.camera,
                            renderCommandEncoder: renderCommandEncoder
                        )
                    }
                }
            }
        }

        renderCommandEncoder.endEncoding()
    }

    private func spawnEffect() {
        let request = EffectSpawnRequest(
            effectID: effectID,
            worldPosition: .zero,
            sourceWorldPosition: SIMD3<Float>(-5, 0, -5),
            ownerObjectID: EffectViewerEffectWorldContext.targetObjectID,
            targetObjectID: EffectViewerEffectWorldContext.targetObjectID,
            sourceObjectID: EffectViewerEffectWorldContext.sourceObjectID
        )
        manager.spawn(request)
        simulateNextTick()
    }

    private func simulateNextTick() {
        manager.stepOneTick(world: world)
        let strPayloads = manager.collectSTRPayloads(fog: fog, world: world)
        let primitivePayloads = manager.collectPrimitivePayloads(fog: fog, world: world)
        tickHistory.append(CachedTick(strPayloads: strPayloads, primitivePayloads: primitivePayloads))

        if tickHistory.count > Self.maxHistoryTicks {
            let overflow = tickHistory.count - Self.maxHistoryTicks
            tickHistory.removeFirst(overflow)
            historyBaseTick += overflow
        }

        simulatedTickCount = tickHistory.count

        if !manager.hasEffects && actualTotalTicks == nil {
            actualTotalTicks = historyBaseTick + tickHistory.count
        }
    }

    private func advancePlayback(atTime time: TimeInterval) {
        guard isPlaying else {
            lastRenderTime = nil
            return
        }

        guard let previousTime = lastRenderTime else {
            lastRenderTime = time
            return
        }
        lastRenderTime = time

        let rawDelta = max(0, min(time - previousTime, 0.1))
        let scaledDelta = rawDelta * playbackRate.rawValue
        tickAccumulator += scaledDelta

        let epsilon: TimeInterval = 1e-9
        var steppedTicks = 0

        while tickAccumulator + epsilon >= EffectManager.tickDuration && steppedTicks < EffectManager.maxTicksPerUpdate {
            tickAccumulator = max(0, tickAccumulator - EffectManager.tickDuration)
            steppedTicks += 1

            let nextTick = currentTick + 1
            let cachedEndTick = historyBaseTick + tickHistory.count

            if nextTick < cachedEndTick {
                currentTick = nextTick
            } else if manager.hasEffects {
                simulateNextTick()
                currentTick = max(historyBaseTick, historyBaseTick + tickHistory.count - 1)
            } else if isLooping {
                replay()
                return
            } else {
                isCompleted = true
                isPlaying = false
                tickAccumulator = 0
                return
            }
        }

        if steppedTicks == EffectManager.maxTicksPerUpdate && tickAccumulator + epsilon >= EffectManager.tickDuration {
            tickAccumulator = tickAccumulator.truncatingRemainder(dividingBy: EffectManager.tickDuration)
        }
    }
}
