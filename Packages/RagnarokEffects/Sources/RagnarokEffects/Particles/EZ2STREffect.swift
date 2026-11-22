//
//  EZ2STREffect.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/22.
//

import Foundation
import RagnarokRendering
import simd

/// Data-driven STR effect (`ID >= 10000`) ported from `CEZ2STREffectEx` in
/// `EffectResourceSwitcher.cpp` and `EZ2STREffectEx.cpp`.
@MainActor
public final class EZ2STREffect: STREffectRenderable {
    public let id: UUID
    public let entry: EZ2STREffectCatalog.Entry

    public var rawEffectID: Int {
        entry.rawEffectID
    }

    public let ownerObjectID: EffectTargetID?
    public let targetObjectID: EffectTargetID?
    public let attachmentKey: EffectAttachmentKey

    public private(set) var worldPosition: SIMD3<Float>
    public private(set) var state = RagEffectSTRState()
    public private(set) var isAlive: Bool = true
    public private(set) var isFinished: Bool = false

    public var transform: STREffectTransform
    public var renderMode: STREffectRenderMode

    public private(set) var isLooping: Bool
    public private(set) var holdsFinalFrame: Bool = false
    public private(set) var isFadingOut: Bool = false
    public var repeatCount: Int = 0
    public var lifeTimeFrames: Int = 0

    private var remainingDelayMs: Int
    private var frameStep: Int
    private var eventFrame: Int = 0
    private var soundTriggered: Bool = false
    private var quakeTriggered: Bool = false

    private var loadedAsset: STREffectAsset?
    private var currentFrame: STREffectAnimation.Frame?

    public init(
        id: UUID = UUID(),
        request: EffectSpawnRequest,
        entry: EZ2STREffectCatalog.Entry
    ) {
        self.id = id
        self.entry = entry
        self.ownerObjectID = request.ownerObjectID
        self.targetObjectID = request.targetObjectID
        self.attachmentKey = request.attachmentKey
        self.worldPosition = request.worldPosition
        self.isLooping = entry.isInfinite
        self.remainingDelayMs = entry.startDelayTime
        self.frameStep = entry.startDelayTime / 16
        self.transform = STREffectTransform(offset: SIMD2<Float>(entry.offsetX, entry.offsetY))

        if entry.isAboveUI {
            self.renderMode = .screen
        } else if entry.isFloor {
            self.renderMode = .ground
        } else {
            self.renderMode = .billboard
        }
    }

    public func setDelayMilliseconds(_ delayMs: Int) {
        remainingDelayMs = delayMs
        frameStep = delayMs / 16
    }

    public func endLoop(hold: Bool) {
        isLooping = false
        holdsFinalFrame = hold
    }

    public func enableTimeLimit() {
        isFadingOut = true
    }

    public func enableGroundRender() {
        renderMode = .ground
    }

    public func tick(context: EffectTickContext) {
        guard isAlive else {
            return
        }

        if isFadingOut {
            transform.alpha -= 0.05
            if transform.alpha <= 0 {
                stop()
                return
            }
        }

        updateWorldPosition(world: context.world)
        triggerTimedEvents(world: context.world)

        if remainingDelayMs > 0 {
            remainingDelayMs -= 16
            eventFrame += 1
            return
        }

        if loadedAsset == nil, let assets = context.assets {
            if let asset = assets.strAsset(atPath: entry.filePath) {
                loadedAsset = asset
            } else if assets.hasFailedSTRAsset(atPath: entry.filePath) {
                stop()
                return
            }
        }

        if let asset = loadedAsset {
            let str = asset.animation.str
            if lifeTimeFrames > 0 && state.frameCounter >= lifeTimeFrames {
                isFinished = true
                stop()
                return
            }

            let stillPlaying = state.step(str: str)
            if stillPlaying {
                currentFrame = state.makeFrame(for: str)
                if entry.isSoundLoop && state.frameCounter == 1 {
                    soundTriggered = false
                    eventFrame = frameStep
                }
            } else {
                isFinished = true
                if holdsFinalFrame {
                    // Hold current state until caller switches or stops.
                } else if isLooping {
                    state.reset(for: str)
                    if state.step(str: str) {
                        currentFrame = state.makeFrame(for: str)
                        if entry.isSoundLoop {
                            soundTriggered = false
                            eventFrame = frameStep
                        }
                    }
                } else if repeatCount > 0 {
                    repeatCount -= 1
                    state.reset(for: str)
                    if state.step(str: str) {
                        currentFrame = state.makeFrame(for: str)
                    }
                } else {
                    stop()
                    return
                }
            }
        }

        eventFrame += 1
    }

    public func stop() {
        isAlive = false
        currentFrame = nil
    }

    public func makeSTRRenderPayloads(
        fog: Fog,
        modelMatrix: simd_float4x4,
        world: any EffectWorldContext
    ) -> [STREffectRenderer.RenderPayload] {
        guard isAlive, let asset = loadedAsset, let frame = currentFrame, !frame.sprites.isEmpty else {
            return []
        }

        let terrainHeightClosure: ((_ worldX: Float, _ worldZ: Float) -> Float)?
        if renderMode == .ground {
            terrainHeightClosure = { worldX, worldZ in
                let effectPos = EffectSpace.toEffectPosition(SIMD3<Float>(worldX, 0, worldZ))
                let effectHeight = world.terrainHeight(atEffectX: effectPos.x, effectZ: effectPos.z)
                return EffectSpace.toWorldHeight(effectHeight)
            }
        } else {
            terrainHeightClosure = nil
        }

        let payload = STREffectRenderer.RenderPayload(
            asset: asset,
            frameIndex: max(0, state.frameCounter - 1),
            frame: frame,
            mode: renderMode,
            worldPosition: worldPosition,
            transform: transform,
            fog: fog,
            modelMatrix: modelMatrix,
            terrainHeight: terrainHeightClosure
        )
        return [payload]
    }

    private func updateWorldPosition(world: any EffectWorldContext) {
        if let trackedID = ownerObjectID ?? targetObjectID,
           let targetState = world.targetState(for: trackedID) {
            worldPosition = targetState.worldPosition
        } else if isLooping, let ownerObjectID, world.targetState(for: ownerObjectID) == nil {
            stop()
            return
        }

        if entry.isToGround {
            let effectPos = EffectSpace.toEffectPosition(worldPosition)
            let effectHeight = world.terrainHeight(atEffectX: effectPos.x, effectZ: effectPos.z)
            worldPosition.y = EffectSpace.toWorldHeight(effectHeight)
        }
    }

    private func triggerTimedEvents(world: any EffectWorldContext) {
        if !entry.soundPath.isEmpty && !soundTriggered && eventFrame >= frameStep + 1 {
            soundTriggered = true
            world.playSound(named: entry.soundPath, atWorldPosition: worldPosition, delay: 0)
        }

        if entry.quakeDelay >= 0 && !quakeTriggered && eventFrame >= entry.quakeDelay {
            quakeTriggered = true
            world.shakeCamera(amplitude: 0.4, duration: 0.3, frequency: 30)
        }
    }
}
