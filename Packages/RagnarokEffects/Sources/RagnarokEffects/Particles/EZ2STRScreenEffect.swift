//
//  EZ2STRScreenEffect.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/23.
//

import Foundation
import RagnarokRendering
import simd

/// Screen/world STR particle effect runtime driven by `STREffectPlaybackState` and `EZ2STRScreenEffectDefinition`.
@MainActor
public final class EZ2STRScreenEffect: STREffectRenderable {
    public let id: UUID
    public let effectID: EffectID

    public var rawEffectID: Int {
        effectID.rawValue
    }

    public let definition: EZ2STRScreenEffectDefinition
    public let strPath: String

    public let ownerObjectID: EffectTargetID?
    public let targetObjectID: EffectTargetID?
    public let sourceObjectID: EffectTargetID?
    public let attachmentKey: EffectAttachmentKey
    public let level: Int

    public private(set) var worldPosition: SIMD3<Float>
    public private(set) var playbackState = STREffectPlaybackState()
    public private(set) var elapsedFrames: Int = 0
    public private(set) var isAlive: Bool = true
    public private(set) var isFinished: Bool = false

    public var transform: STREffectTransform
    public var renderMode: STREffectRenderMode
    public var isLooping: Bool
    public var holdsFinalFrame: Bool = false
    public var repeatCount: Int
    public var lifeTimeFrames: Int
    public private(set) var remainingDelayMs: Int = 0

    public var fadePulse: Bool = false
    public var fadePulseScale: Float = 1.0
    public var followCamera: Bool
    public private(set) var overlayColor: UInt32 = 0

    public var overlayAlpha: Float {
        Float((overlayColor >> 24) & 0xFF) / 255.0
    }

    public private(set) var windowOffset: SIMD3<Float> = .zero
    public private(set) var isAttachedToWindow: Bool = false
    public private(set) var windowID: Int = -1
    public var isVisible: Bool = true

    private var lastCameraYaw: Float?
    private var baseOffset: SIMD2<Float> = .zero
    private var loadedAsset: STREffectAsset?
    private var currentFrame: STREffectAnimation.Frame?

    public init(
        id: UUID = UUID(),
        request: EffectSpawnRequest,
        definition: EZ2STRScreenEffectDefinition
    ) {
        self.id = id
        self.effectID = definition.effectID
        self.definition = definition
        self.strPath = definition.expandedSTRPath()

        self.ownerObjectID = request.ownerObjectID
        self.targetObjectID = request.targetObjectID
        self.sourceObjectID = request.sourceObjectID
        self.attachmentKey = request.attachmentKey
        self.level = request.level
        self.worldPosition = request.worldPosition

        self.renderMode = definition.renderMode
        self.isLooping = definition.isLooping || definition.isHeadEffect
        self.repeatCount = definition.defaultRepeatCount
        self.followCamera = definition.followCamera

        let initialScale = definition.levelScales[request.level] ?? definition.defaultScale
        var initialAngle: Float = 0
        if definition.aimMode != .none, let sourceWorldPosition = request.sourceWorldPosition {
            initialAngle = definition.aimMode.angle(from: sourceWorldPosition, to: request.worldPosition)
        }
        self.transform = STREffectTransform(scale: initialScale, angle: initialAngle)

        if let duration = request.duration, duration > 0 {
            self.lifeTimeFrames = max(1, Int((duration * EffectManager.tickRate).rounded()))
        } else {
            self.lifeTimeFrames = definition.defaultLifeTimeFrames ?? 0
        }
    }

    public func setLifeTime(frames: Int) {
        lifeTimeFrames = max(0, frames)
    }

    public func setRepeat(_ count: Int) {
        repeatCount = max(0, count - 1)
    }

    public func setDelayMilliseconds(_ delayMs: Int) {
        remainingDelayMs = max(0, delayMs)
    }

    public func setAngle(_ angle: Float) {
        transform.angle = angle
    }

    public func setScale(_ scale: Float) {
        transform.scale = scale
    }

    public func setAlpha(_ alpha: Float) {
        transform.alpha = alpha
    }

    public func setWindowOffset(_ offset: SIMD3<Float>, attachToWindow: Bool, windowID: Int = -1) {
        windowOffset = offset
        baseOffset = SIMD2<Float>(offset.x, offset.y)
        transform.offset = baseOffset
        if attachToWindow {
            isAttachedToWindow = true
            self.windowID = windowID
        }
    }

    public func advanceFrame(fraction: Float) {
        guard let asset = loadedAsset else {
            return
        }
        let str = asset.animation.str
        let count = Int(Float(str.maxKeyframeIndex) * fraction)
        guard count > 0 else {
            return
        }
        for _ in 0..<count {
            if playbackState.step(str: str) {
                currentFrame = playbackState.makeFrame(for: str)
            } else {
                break
            }
        }
    }

    public func tick(context: EffectTickContext) {
        guard isAlive else {
            return
        }

        if followCamera {
            updateCameraAngle(world: context.world)
        }

        updateWorldPositionAndHeadOffset(world: context.world)
        guard isAlive else {
            return
        }

        triggerTimedEvents(world: context.world)

        if definition.overlayColorStep > 0 {
            let nextColor = UInt64(overlayColor) + UInt64(definition.overlayColorStep)
            overlayColor = UInt32(min(UInt64(0xAA00_0000), nextColor))
        }

        if remainingDelayMs > 0 {
            remainingDelayMs -= 16
            elapsedFrames += 1
            return
        }

        if loadedAsset == nil, let assets = context.assets {
            if let asset = assets.strAsset(atPath: strPath, usesMinimalEffects: context.usesMinimalEffects) {
                loadedAsset = asset
            } else if assets.hasFailedSTRAsset(atPath: strPath, usesMinimalEffects: context.usesMinimalEffects) {
                stop()
                return
            }
        }

        if let asset = loadedAsset {
            let str = asset.animation.str
            if lifeTimeFrames > 0 && playbackState.frameCounter >= lifeTimeFrames {
                isFinished = true
                stop()
                return
            }

            let stillPlaying = playbackState.step(str: str)
            if stillPlaying {
                currentFrame = playbackState.makeFrame(for: str)
            } else {
                isFinished = true
                if holdsFinalFrame {
                    // Hold current frame until caller stops.
                } else if isLooping {
                    playbackState.reset(for: str)
                    if playbackState.step(str: str) {
                        currentFrame = playbackState.makeFrame(for: str)
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

        elapsedFrames += 1
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
        guard isAlive, isVisible, let asset = loadedAsset, let frame = currentFrame, !frame.sprites.isEmpty else {
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
            frameIndex: max(0, playbackState.frameCounter - 1),
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

    private func updateCameraAngle(world: any EffectWorldContext) {
        let yaw = world.cameraYawDegrees
        guard let previousYaw = lastCameraYaw else {
            lastCameraYaw = yaw
            return
        }
        guard yaw != previousYaw else {
            return
        }

        var angle = previousYaw - yaw + transform.angle
        if angle < 0 {
            angle += 360
        } else if angle > 360 {
            angle -= 360
        }
        transform.angle = angle
        lastCameraYaw = yaw
    }

    private func updateWorldPositionAndHeadOffset(world: any EffectWorldContext) {
        let trackedID = ownerObjectID ?? targetObjectID
        let targetState = trackedID.flatMap { world.targetState(for: $0) }

        if (definition.isHeadEffect || definition.isRetained),
           ownerObjectID != nil,
           targetState == nil {
            stop()
            return
        }

        guard let targetState else {
            return
        }

        worldPosition = targetState.worldPosition

        if definition.isHeadEffect || definition.isAttachedToHead {
            let baseHeight = definition.ignoresRidingHeight
                ? 18.0
                : (targetState.headHeight * EffectSpace.worldToEffectScale)
            let effectOffsetY = baseHeight + definition.headOffsetYDelta - 7.0
            let factor: Float = fadePulse ? fadePulseScale : 1.0
            worldPosition.y += EffectSpace.toWorldHeight(-effectOffsetY * factor)
            transform.offset.x = baseOffset.x + definition.headOffsetX * factor
            transform.offset.y = baseOffset.y
        }
    }

    private func triggerTimedEvents(world: any EffectWorldContext) {
        for sound in definition.sounds where sound.tick == elapsedFrames {
            if sound.chanceDenominator > 1 && Int.random(in: 0..<sound.chanceDenominator) != 0 {
                continue
            }
            guard let soundName = sound.names.count == 1 ? sound.names.first : sound.names.randomElement() else {
                continue
            }
            world.playSound(named: soundName, atWorldPosition: worldPosition, delay: 0)
        }

        if let periodic = definition.periodicSound {
            let delta = elapsedFrames - periodic.startTick
            if delta >= 0 && delta % periodic.intervalTicks == 0 {
                world.playSound(named: periodic.name, atWorldPosition: worldPosition, delay: 0)
            }
        }

        if definition.cameraShakeTicks.contains(elapsedFrames) {
            world.shakeCamera(amplitude: 0.4, duration: 0.3, frequency: 30)
        }
    }
}
