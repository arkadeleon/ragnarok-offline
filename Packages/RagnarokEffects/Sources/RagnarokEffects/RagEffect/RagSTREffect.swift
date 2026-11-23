//
//  RagSTREffect.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/21.
//

import Foundation
import RagnarokRendering
import simd

/// Pure-STR `CRagEffect` runtime instance driven by `STREffectPlaybackState` and `RagSTREffectDefinition`.
@MainActor
public final class RagSTREffect: STREffectRenderable {
    public let id: UUID
    public let effectID: EffectID

    public var rawEffectID: Int {
        effectID.rawValue
    }

    public let definition: RagSTREffectDefinition
    public let resolvedSTRPath: String

    public let ownerObjectID: EffectTargetID?
    public let targetObjectID: EffectTargetID?
    public let attachmentKey: EffectAttachmentKey

    public private(set) var worldPosition: SIMD3<Float>
    public private(set) var stateCount: Int = 0
    public private(set) var playbackState: STREffectPlaybackState
    public let durationTicks: Int?

    public private(set) var isAlive: Bool = true

    private var loadedAsset: STREffectAsset?
    private var currentFrame: STREffectAnimation.Frame?

    public init(
        id: UUID = UUID(),
        request: EffectSpawnRequest,
        definition: RagSTREffectDefinition,
        usesMinimalEffects: Bool = false
    ) {
        self.id = id
        self.effectID = definition.effectID
        self.definition = definition
        self.resolvedSTRPath = definition.resolveSTRPath(usesMinimalEffects: usesMinimalEffects)
        self.ownerObjectID = request.ownerObjectID
        self.targetObjectID = request.targetObjectID
        self.attachmentKey = request.attachmentKey
        self.worldPosition = request.worldPosition
        self.playbackState = STREffectPlaybackState(loopLimit: definition.loopLimit)

        if let duration = request.duration, duration > 0 {
            self.durationTicks = max(1, Int((duration * EffectManager.tickRate).rounded()))
        } else if definition.effectID.defaultLifetimeTicks > 0 {
            self.durationTicks = definition.effectID.defaultLifetimeTicks
        } else {
            self.durationTicks = nil
        }
    }

    public func tick(context: EffectTickContext) {
        guard isAlive else {
            return
        }

        updateWorldPosition(world: context.world)
        triggerTimedEvents(world: context.world)

        if loadedAsset == nil, let assets = context.assets {
            if let asset = assets.strAsset(atPath: resolvedSTRPath, usesMinimalEffects: context.usesMinimalEffects) {
                loadedAsset = asset
            } else if assets.hasFailedSTRAsset(atPath: resolvedSTRPath, usesMinimalEffects: context.usesMinimalEffects) {
                isAlive = false
                currentFrame = nil
                return
            }
        }

        if let asset = loadedAsset {
            let stillPlaying = playbackState.step(str: asset.animation.str)
            if stillPlaying {
                currentFrame = playbackState.makeFrame(for: asset.animation.str)
            } else if definition.restartsOnEnd {
                playbackState.reset(for: asset.animation.str)
                if playbackState.step(str: asset.animation.str) {
                    currentFrame = playbackState.makeFrame(for: asset.animation.str)
                } else {
                    currentFrame = nil
                }
            } else {
                currentFrame = nil
                if definition.endsWhenSTRCompletes {
                    isAlive = false
                    return
                }
            }
        }

        stateCount += 1
        if let durationTicks, stateCount >= durationTicks {
            isAlive = false
            currentFrame = nil
        }
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

        let transform = STREffectTransform(offset: SIMD2<Float>(0, definition.yOffset + 80))
        let payload = STREffectRenderer.RenderPayload(
            asset: asset,
            frameIndex: max(0, playbackState.frameCounter - 1),
            frame: frame,
            mode: .billboard,
            worldPosition: worldPosition,
            transform: transform,
            fog: fog,
            modelMatrix: modelMatrix
        )
        return [payload]
    }

    private func updateWorldPosition(world: any EffectWorldContext) {
        let trackedID: EffectTargetID? = definition.usesTargetPosition
            ? (targetObjectID ?? ownerObjectID)
            : (ownerObjectID ?? targetObjectID)

        if let trackedID, let targetState = world.targetState(for: trackedID) {
            worldPosition = targetState.worldPosition
        }
    }

    private func triggerTimedEvents(world: any EffectWorldContext) {
        for sound in definition.sounds where sound.tick == stateCount {
            if sound.chanceDenominator > 1 && Int.random(in: 0..<sound.chanceDenominator) != 0 {
                continue
            }
            guard let soundName = sound.names.count == 1 ? sound.names.first : sound.names.randomElement() else {
                continue
            }
            world.playSound(named: soundName, atWorldPosition: worldPosition, delay: 0)
        }

        if definition.cameraShakeTicks.contains(stateCount) {
            world.shakeCamera(amplitude: 0.4, duration: 0.3, frequency: 30)
        }

        if let targetTint = definition.targetTint, let targetID = ownerObjectID ?? targetObjectID {
            switch targetTint {
            case .constant(let color):
                world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            case .rejectSwordFlicker(let durationTicks):
                if stateCount < durationTicks {
                    let level: Float = (stateCount % 6) < 3 ? (100.0 / 255.0) : (250.0 / 255.0)
                    let color = SIMD4<Float>(level, level, level, 1)
                    world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
                }
            }
        }
    }
}
