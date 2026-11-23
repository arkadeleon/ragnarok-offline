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
    public private(set) var playbackState = STREffectPlaybackState()
    public private(set) var elapsedTicks: Int = 0
    public private(set) var isAlive: Bool = true
    public private(set) var isFinished: Bool = false

    public var transform: STREffectTransform
    public var renderMode: STREffectRenderMode

    public private(set) var isLooping: Bool
    public private(set) var holdsFinalFrame: Bool = false
    public private(set) var isFadingOut: Bool = false
    public var repeatCount: Int = 0
    public var lifetimeTicks: Int = 0

    private var remainingDelayMs: Int
    private var delayTicks: Int
    private var eventTick: Int = 0
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
        self.delayTicks = entry.startDelayTime / 16
        self.transform = STREffectTransform(offset: SIMD2<Float>(entry.offsetX, entry.offsetY))

        if entry.isAboveUI {
            self.renderMode = .screen
        } else if entry.isFloor {
            self.renderMode = .ground
        } else {
            self.renderMode = .billboard
        }

        if let duration = request.duration, duration > 0 {
            self.lifetimeTicks = max(1, Int((duration * EffectManager.tickRate).rounded()))
        }
    }

    public func setDelayMilliseconds(_ delayMs: Int) {
        remainingDelayMs = delayMs
        delayTicks = delayMs / 16
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

        if lifetimeTicks > 0 && elapsedTicks >= lifetimeTicks {
            isFinished = true
            stop()
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
            eventTick += 1
            elapsedTicks += 1
            return
        }

        if loadedAsset == nil, let assets = context.assets {
            if let asset = assets.strAsset(atPath: entry.filePath, usesMinimalEffects: context.usesMinimalEffects) {
                loadedAsset = asset
            } else if assets.hasFailedSTRAsset(atPath: entry.filePath, usesMinimalEffects: context.usesMinimalEffects) {
                stop()
                return
            }
        }

        if let asset = loadedAsset {
            let str = asset.animation.str
            let stillPlaying = playbackState.step(str: str)
            if stillPlaying {
                currentFrame = playbackState.makeFrame(for: str)
                if entry.isSoundLoop && playbackState.frameCounter == 1 {
                    soundTriggered = false
                    eventTick = delayTicks
                }
            } else {
                isFinished = true
                if holdsFinalFrame {
                    // Hold current state until caller switches or stops.
                } else if isLooping {
                    playbackState.reset(for: str)
                    if playbackState.step(str: str) {
                        currentFrame = playbackState.makeFrame(for: str)
                        if entry.isSoundLoop {
                            soundTriggered = false
                            eventTick = delayTicks
                        }
                    }
                } else if repeatCount > 0 {
                    repeatCount -= 1
                    playbackState.reset(for: str)
                    if playbackState.step(str: str) {
                        currentFrame = playbackState.makeFrame(for: str)
                    }
                } else {
                    stop()
                    return
                }
            }
        }

        eventTick += 1
        elapsedTicks += 1
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

        let payload = STREffectRenderer.RenderPayload(
            asset: asset,
            frameIndex: max(0, playbackState.frameCounter - 1),
            frame: frame,
            mode: renderMode,
            worldPosition: worldPosition,
            transform: transform,
            fog: fog,
            modelMatrix: modelMatrix,
            terrainHeight: renderMode == .ground ? { world.worldTerrainHeight(atWorldX: $0, worldZ: $1) } : nil
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
            worldPosition.y = world.worldTerrainHeight(atWorldX: worldPosition.x, worldZ: worldPosition.z)
        }
    }

    private func triggerTimedEvents(world: any EffectWorldContext) {
        if !entry.soundPath.isEmpty && !soundTriggered && eventTick >= delayTicks + 1 {
            soundTriggered = true
            world.playSound(named: entry.soundPath, atWorldPosition: worldPosition, delay: 0)
        }

        if entry.quakeDelay >= 0 && !quakeTriggered && eventTick >= entry.quakeDelay {
            quakeTriggered = true
            world.shakeCamera(amplitude: 0.4, duration: 0.3, frequency: 30)
        }
    }
}
