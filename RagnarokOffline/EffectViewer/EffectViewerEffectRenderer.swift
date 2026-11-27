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

    var next: EffectViewerPlaybackRate {
        switch self {
        case .normal: .half
        case .half: .quarter
        case .quarter: .tenth
        case .tenth: .normal
        }
    }
}

@MainActor
@Observable
final class EffectViewerEffectRenderer: Renderer {
    private enum RenderPayload {
        case target(EffectViewerTargetRenderer.RenderPayload)
        case str(STREffectRenderer.RenderPayload)
        case primitive(EffectPrimitiveBatchRenderer.RenderPayload)
    }

    private struct CachedTick {
        let targetPayloads: [EffectViewerTargetRenderer.RenderPayload]
        let strPayloads: [STREffectRenderer.RenderPayload]
        let primitivePayloads: [EffectPrimitiveBatchRenderer.RenderPayload]
    }

    private static let maxHistoryTicks = 1800
    private static let maxSeekAdvanceTicks = 600

    let device: any MTLDevice
    let configuration: RenderConfiguration
    let camera: OrbitalCamera

    private(set) var effectID: EffectID?

    var isPlaying = true
    private(set) var isCompleted = false
    var isLooping = true
    var showsTarget = false
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

    @ObservationIgnored var targetSprite: EffectViewerTargetSprite?

    @ObservationIgnored private let assetStore: EffectAssetStore
    @ObservationIgnored private let world: EffectViewerEffectWorldContext
    @ObservationIgnored private let fog = Fog()
    @ObservationIgnored private let renderQueue = RenderQueue<RenderPayload>()
    @ObservationIgnored private let stageRenderer: EffectViewerStageRenderer
    @ObservationIgnored private let targetRenderer: EffectViewerTargetRenderer
    @ObservationIgnored private let strRenderer: STREffectRenderer
    @ObservationIgnored private let primitiveRenderer: EffectPrimitiveBatchRenderer

    @ObservationIgnored private var ez2strEffectCatalog: EZ2STREffectCatalog?
    @ObservationIgnored private var manager: EffectManager
    @ObservationIgnored private var tickHistory: [CachedTick] = []
    @ObservationIgnored private var lastRenderTime: TimeInterval?
    @ObservationIgnored private var tickAccumulator: TimeInterval = 0

    init(
        device: any MTLDevice,
        configuration: RenderConfiguration,
        effectID: EffectID? = nil,
        resourceManager: ResourceManager,
        ez2strEffectCatalog: EZ2STREffectCatalog? = nil,
        targetSprite: EffectViewerTargetSprite? = nil
    ) throws {
        self.device = device
        self.configuration = configuration
        self.camera = Self.makeDefaultCamera()
        self.targetSprite = targetSprite

        let assetStore = EffectAssetStore(device: device, resourceManager: resourceManager)
        self.assetStore = assetStore
        self.world = EffectViewerEffectWorldContext()
        self.stageRenderer = try EffectViewerStageRenderer(device: device, configuration: configuration)
        self.targetRenderer = try EffectViewerTargetRenderer(device: device, configuration: configuration)
        self.strRenderer = try STREffectRenderer(device: device, configuration: configuration)
        self.primitiveRenderer = try EffectPrimitiveBatchRenderer(device: device, configuration: configuration)

        self.ez2strEffectCatalog = ez2strEffectCatalog
        self.manager = EffectManager(assetStore: assetStore, ez2strEffectCatalog: ez2strEffectCatalog)

        load(effectID: effectID)
    }

    func load(effectID: EffectID?) {
        self.effectID = effectID
        resetSimulation()

        guard let effectID else {
            estimatedTotalTicks = nil
            isPlaying = false
            return
        }

        let lifetime = effectID.defaultLifetimeTicks
        estimatedTotalTicks = (1..<999).contains(lifetime) ? lifetime : nil
        isPlaying = true
        spawnEffect(effectID)
    }

    func updateEZ2STREffectCatalog(_ catalog: EZ2STREffectCatalog?) {
        ez2strEffectCatalog = catalog
        manager.ez2strEffectCatalog = catalog
    }

    func togglePlayPause() {
        guard effectID != nil else {
            return
        }
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
        guard let effectID else {
            return
        }
        if historyBaseTick == 0 && !tickHistory.isEmpty && !manager.hasEffects {
            currentTick = 0
            isCompleted = false
            tickAccumulator = 0
            lastRenderTime = nil
            isPlaying = true
            return
        }

        resetSimulation()
        isPlaying = true
        spawnEffect(effectID)
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

    func cyclePlaybackRate() {
        playbackRate = playbackRate.next
    }

    func toggleLooping() {
        isLooping.toggle()
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

    func render(frame: RenderFrame) {
        advancePlayback(atTime: frame.time)

        let renderPassDescriptor = frame.renderPassDescriptor
        renderPassDescriptor.colorAttachments[0].loadAction = .dontCare
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.depthAttachment.clearDepth = configuration.clearDepth

        guard let renderCommandEncoder = frame.commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        renderQueue.removeAll()

        let historyIndex = currentTick - historyBaseTick
        if tickHistory.indices.contains(historyIndex) {
            let cachedTick = tickHistory[historyIndex]
            if showsTarget, targetSprite != nil {
                for payload in cachedTick.targetPayloads {
                    targetRenderer.submit(
                        payload: payload,
                        into: renderQueue,
                        transformPayload: RenderPayload.target
                    )
                }
            }
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

            stageRenderer.renderBackdrop(viewport: view.viewport, renderCommandEncoder: renderCommandEncoder)

            renderQueue.sort(camera: view.camera)

            for bucket in RenderPassBucket.allCases {
                for item in renderQueue.items(in: bucket) {
                    switch item.payload {
                    case .target(let payload):
                        if let targetSprite {
                            targetRenderer.render(
                                payload: payload,
                                targetSprite: targetSprite,
                                viewport: view.viewport,
                                camera: view.camera,
                                renderCommandEncoder: renderCommandEncoder
                            )
                        }
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

                if bucket == .opaque {
                    stageRenderer.renderGroundGrid(camera: view.camera, renderCommandEncoder: renderCommandEncoder)
                }
            }
        }

        renderCommandEncoder.endEncoding()
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

    private func resetSimulation() {
        manager.removeAll()
        manager = EffectManager(assetStore: assetStore, ez2strEffectCatalog: ez2strEffectCatalog)
        world.resetModifiers()
        tickHistory.removeAll(keepingCapacity: true)
        historyBaseTick = 0
        simulatedTickCount = 0
        actualTotalTicks = nil
        currentTick = 0
        isCompleted = false
        tickAccumulator = 0
        lastRenderTime = nil
    }

    private func spawnEffect(_ effectID: EffectID) {
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
        world.targetModifiers.update(deltaTime: EffectManager.tickDuration)
        manager.stepOneTick(world: world)
        let targetPayloads = world.collectTargetPayloads()
        let strPayloads = manager.collectSTRPayloads(fog: fog, world: world)
        let primitivePayloads = manager.collectPrimitivePayloads(fog: fog, world: world)
        tickHistory.append(
            CachedTick(
                targetPayloads: targetPayloads,
                strPayloads: strPayloads,
                primitivePayloads: primitivePayloads
            )
        )

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
                if historyBaseTick == 0 && !tickHistory.isEmpty {
                    currentTick = 0
                    isCompleted = false
                } else {
                    replay()
                    return
                }
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
