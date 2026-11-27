//
//  RagEffect.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/24.
//

import Foundation
import RagnarokRendering
import simd

/// Procedural effect host running a 60Hz `stateCnt` state machine and
/// coordinating owned `EffectPrimitive` child instances and optional STR playback.
@MainActor
public final class RagEffect: EffectPrimitiveRenderable, STREffectRenderable {
    public typealias ProcessHandler = (RagEffect, EffectTickContext) -> Bool

    public let id: UUID
    public let effectID: EffectID
    public let ownerObjectID: EffectTargetID?
    public let targetObjectID: EffectTargetID?
    public let sourceObjectID: EffectTargetID?
    public let attachmentKey: EffectAttachmentKey

    public var position: SIMD3<Float>
    public var sourcePosition: SIMD3<Float>?
    public var deltaPos: SIMD3<Float> = .zero
    public var deltaPos2: SIMD3<Float> = .zero
    public var deltaPos3: SIMD3<Float> = .zero
    public var param: [Float] = [0, 0, 0, 0]
    public var longitude: Float = 0
    public var latitude: Float = 0
    public var defZ: UInt32 = 0
    public var isDirection: UInt32 = 0
    public var level: Int
    public var flag: UInt32 = 0
    public var count: UInt32 = 0
    public var stateCnt: Int = 0
    public var duration: Int
    public var tag: UInt32 = 0
    public var visibilityFlags: UInt8 = 0
    public var forceRender: Bool = false

    /// Optional `[red, green, blue, dstBlend]` override channels applied by child primitives (`-1` means unset).
    public var colorChannels: [Int32] = [-1, -1, -1, -1]

    public private(set) var primitives: [EffectPrimitive] = []
    public private(set) var isMasterAlive: Bool = true
    public private(set) var strPath: String?
    public var strPlaybackState: STREffectPlaybackState?

    public var worldPosition: SIMD3<Float> {
        EffectSpace.toWorldPosition(position)
    }

    public var isAlive: Bool {
        isMasterAlive || !primitives.isEmpty
    }

    private var onProcess: ProcessHandler?
    private weak var lastAssets: EffectAssetStore?
    private var hasSyncedInitialTargetFacing: Bool = false
    private var loadedSTRAsset: STREffectAsset?
    private var currentSTRFrame: STREffectAnimation.Frame?
    private var currentSTROffset: SIMD2<Float> = SIMD2<Float>(0, -80)
    private var currentSTRWorldPosition: SIMD3<Float>?

    public init(
        id: UUID,
        request: EffectSpawnRequest,
        duration: Int? = nil,
        onProcess: ProcessHandler? = nil
    ) {
        self.id = id
        self.effectID = request.effectID
        self.ownerObjectID = request.ownerObjectID
        self.targetObjectID = request.targetObjectID
        self.sourceObjectID = request.sourceObjectID
        self.attachmentKey = request.attachmentKey
        self.position = request.effectPosition
        self.sourcePosition = request.sourceEffectPosition
        if let deltaPos = request.deltaPos {
            self.deltaPos = deltaPos
        }
        if let extraParams = request.extraParams {
            self.deltaPos2 = extraParams
        }
        for index in 0..<min(self.param.count, request.parameters.count) {
            self.param[index] = request.parameters[index]
        }
        self.level = request.level
        if let duration {
            self.duration = duration
        } else if let requestDuration = request.duration, requestDuration > 0 {
            self.duration = max(1, Int((requestDuration * EffectManager.tickRate).rounded()))
        } else {
            self.duration = request.effectID.defaultLifetimeTicks
        }
        self.onProcess = onProcess
    }

    @discardableResult
    public func launchPrimitive(
        _ primitiveID: EffectPrimitiveID,
        deltaPos: SIMD3<Float> = .zero
    ) -> EffectPrimitive {
        let primitive = EffectPrimitive(id: primitiveID)
        primitive.initialize(master: self, id: primitiveID, deltaPos: deltaPos)
        primitives.append(primitive)
        return primitive
    }

    public func configureSTR(path: String, loopLimit: Int = 0) {
        strPath = path
        loadedSTRAsset = nil
        currentSTRFrame = nil
        strPlaybackState = STREffectPlaybackState(loopLimit: loopLimit)
    }

    private enum STRStepResult {
        case pending
        case playing
        case completed
        case failed
    }

    @discardableResult
    public func configureSTRFromDefinition(usesMinimalEffects: Bool = false) -> Bool {
        guard let definition = STRDefinition.definition(for: effectID) else {
            return false
        }
        configureSTR(
            path: definition.resolveSTRPath(usesMinimalEffects: usesMinimalEffects),
            loopLimit: definition.loopLimit
        )
        return true
    }

    @discardableResult
    public func processEZ2STR(
        offset: SIMD3<Float> = SIMD3<Float>(0, -80, 0),
        atEffectPosition effectPosition: SIMD3<Float>? = nil,
        restartsOnEnd: Bool = false,
        context: EffectTickContext
    ) -> Bool {
        let result = stepEZ2STR(
            offset: offset,
            atEffectPosition: effectPosition,
            restartsOnEnd: restartsOnEnd,
            context: context
        )

        switch result {
        case .pending, .playing:
            return true
        case .completed, .failed:
            return false
        }
    }

    func processSTRDefinition(_ definition: STRDefinition, context: EffectTickContext) -> Bool {
        let trackedID: EffectTargetID? = definition.usesTargetPosition
            ? (targetObjectID ?? ownerObjectID)
            : (ownerObjectID ?? targetObjectID)
        if let trackedID, let targetState = context.world.targetState(for: trackedID), targetState.isValid {
            position = targetState.effectPosition
        }

        for sound in definition.sounds {
            sound.playIfMatching(tick: stateCnt, atWorldPosition: worldPosition, world: context.world)
        }

        if definition.cameraShakeTicks.contains(stateCnt) {
            context.world.shakeCamera(amplitude: 0.4, duration: 0.3, frequency: 30)
        }

        if let targetTint = definition.targetTint, let targetID = ownerObjectID ?? targetObjectID {
            switch targetTint {
            case .constant(let color):
                context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
            case .rejectSwordFlicker(let durationTicks):
                if stateCnt < durationTicks {
                    let level: Float = (stateCnt % 6) < 3 ? (100.0 / 255.0) : (250.0 / 255.0)
                    let color = SIMD4<Float>(level, level, level, 1)
                    context.world.applyTargetModifier(.tint(color: color, durationTicks: 2), to: targetID)
                }
            }
        }

        let result = stepEZ2STR(
            offset: SIMD3<Float>(0, definition.yOffset, 0),
            restartsOnEnd: definition.restartsOnEnd,
            context: context
        )

        switch result {
        case .pending, .playing:
            return true
        case .completed:
            return !definition.endsWhenSTRCompletes
        case .failed:
            return false
        }
    }

    private func stepEZ2STR(
        offset: SIMD3<Float>,
        atEffectPosition effectPosition: SIMD3<Float>? = nil,
        restartsOnEnd: Bool,
        context: EffectTickContext
    ) -> STRStepResult {
        if strPath == nil {
            guard configureSTRFromDefinition(usesMinimalEffects: context.usesMinimalEffects) else {
                return .failed
            }
        }
        guard let path = strPath else {
            return .failed
        }

        if loadedSTRAsset == nil, let assets = context.assets {
            if let asset = assets.strAsset(atPath: path, usesMinimalEffects: context.usesMinimalEffects) {
                loadedSTRAsset = asset
            } else if assets.hasFailedSTRAsset(atPath: path, usesMinimalEffects: context.usesMinimalEffects) {
                currentSTRFrame = nil
                return .failed
            } else {
                currentSTRFrame = nil
                return .pending
            }
        }

        guard let asset = loadedSTRAsset else {
            currentSTRFrame = nil
            return .pending
        }

        var playbackState = strPlaybackState ?? STREffectPlaybackState()
        var stillPlaying = playbackState.step(str: asset.animation.str)
        if !stillPlaying && restartsOnEnd {
            playbackState.reset(for: asset.animation.str)
            stillPlaying = playbackState.step(str: asset.animation.str)
        }
        strPlaybackState = playbackState

        if stillPlaying {
            currentSTRFrame = playbackState.makeFrame(for: asset.animation.str)
            currentSTROffset = SIMD2<Float>(offset.x, offset.y)
            currentSTRWorldPosition = EffectSpace.toWorldPosition(effectPosition ?? position)
            defZ = (offset.x == 0 && offset.y == -80 && offset.z == 0) ? 0 : 1
            return .playing
        } else {
            currentSTRFrame = nil
            return .completed
        }
    }

    @discardableResult
    public func processEZ2STRRaised(context: EffectTickContext) -> Bool {
        processEZ2STR(offset: SIMD3<Float>(0, -80, 0), context: context)
    }

    @discardableResult
    public func processEZ2STRAtTarget(context: EffectTickContext) -> Bool {
        processEZ2STR(offset: SIMD3<Float>(0, -80, 0), atEffectPosition: deltaPos, context: context)
    }

    public func tick(context: EffectTickContext) {
        lastAssets = context.assets

        if let targetObjectID, let targetState = context.world.targetState(for: targetObjectID), targetState.isValid {
            position = targetState.effectPosition
        }
        if let sourceObjectID, let sourceState = context.world.targetState(for: sourceObjectID), sourceState.isValid {
            sourcePosition = sourceState.effectPosition
        }
        if !hasSyncedInitialTargetFacing {
            hasSyncedInitialTargetFacing = true
            if let facingID = targetObjectID ?? ownerObjectID,
               let targetState = context.world.targetState(for: facingID),
               targetState.isValid {
                longitude = targetState.facingAngle
            }
        }

        if isMasterAlive {
            if let onProcess, !onProcess(self, context) {
                retireMaster()
            } else {
                stateCnt += 1
                if stateCnt >= duration {
                    retireMaster()
                }
            }
        }

        for primitive in primitives where primitive.isAlive {
            primitive.tick(context: context)
        }
        primitives.removeAll { !$0.isAlive }
    }

    public func stop() {
        isMasterAlive = false
        currentSTRFrame = nil
        loadedSTRAsset = nil
        for primitive in primitives {
            primitive.stop()
        }
        primitives.removeAll()
    }

    public func collectPrimitiveBatches(
        into collector: inout EffectPrimitiveBatchCollector,
        fog: Fog,
        modelMatrix: simd_float4x4,
        world: any EffectWorldContext
    ) {
        for primitive in primitives where primitive.isAlive {
            primitive.collectBatches(into: &collector, world: world, assets: lastAssets)
        }
    }

    public func makeSTRRenderPayloads(
        fog: Fog,
        modelMatrix: simd_float4x4,
        world: any EffectWorldContext
    ) -> [STREffectRenderer.RenderPayload] {
        guard isAlive,
              let asset = loadedSTRAsset,
              let frame = currentSTRFrame,
              !frame.sprites.isEmpty,
              let playbackState = strPlaybackState else {
            return []
        }

        let payload = STREffectRenderer.RenderPayload(
            asset: asset,
            frameIndex: max(0, playbackState.frameCounter - 1),
            frame: frame,
            mode: .billboard,
            worldPosition: currentSTRWorldPosition ?? EffectSpace.toWorldPosition(position),
            transform: STREffectTransform(offset: currentSTROffset),
            fog: fog,
            modelMatrix: modelMatrix
        )
        return [payload]
    }

    static func effectHeading(fromX x: Float, fromZ z: Float, toX targetX: Float, toZ targetZ: Float) -> Float {
        let deltaX = targetX - x
        let deltaZ = targetZ - z
        var angle = (atan2f(deltaX, -deltaZ) / EffectSpace.clientPi) * 180.0
        if angle >= 360.0 {
            angle -= 360.0
        }
        if angle < 0.0 {
            angle += 360.0
        }
        return angle
    }

    static func effectDistanceXZ(from: SIMD3<Float>, to: SIMD3<Float>) -> Float {
        let dx = to.x - from.x
        let dz = to.z - from.z
        return sqrtf(dz * dz + dx * dx)
    }

    func directionalLaunchEndpoints() -> (origin: SIMD3<Float>, destination: SIMD3<Float>) {
        let origin = sourcePosition ?? position
        let destination = sourcePosition != nil
            ? position
            : (deltaPos == .zero ? position + SIMD3<Float>(25, 0, 0) : deltaPos)
        return (origin, destination)
    }

    private func retireMaster() {
        isMasterAlive = false
        currentSTRFrame = nil
        for primitive in primitives {
            primitive.detachMaster()
        }
    }
}
