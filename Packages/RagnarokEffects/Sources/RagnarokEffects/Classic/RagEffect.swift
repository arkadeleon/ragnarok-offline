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
/// coordinating owned `EffectPrimitive` child instances.
@MainActor
public final class RagEffect: EffectPrimitiveRenderable {
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
    public var level: Int
    public var flag: UInt32 = 0
    public var count: UInt32 = 0
    public var stateCnt: Int = 0
    public var duration: Int

    /// Optional `[red, green, blue, dstBlend]` override channels applied by child primitives (`-1` means unset).
    public var colorChannels: [Int32] = [-1, -1, -1, -1]

    public private(set) var primitives: [EffectPrimitive] = []
    public private(set) var isMasterAlive: Bool = true

    public var isAlive: Bool {
        isMasterAlive || !primitives.isEmpty
    }

    private var onProcess: ProcessHandler?
    private weak var lastAssets: EffectAssetStore?

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
        if let extraParams = request.extraParams {
            self.deltaPos2 = extraParams
        }
        for index in 0..<min(self.param.count, request.parameters.count) {
            self.param[index] = request.parameters[index]
        }
        self.level = request.level
        if let duration {
            self.duration = duration
        } else if let requestDuration = request.duration {
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

    public func tick(context: EffectTickContext) {
        lastAssets = context.assets

        if let targetObjectID, let targetState = context.world.targetState(for: targetObjectID), targetState.isValid {
            position = targetState.effectPosition
        }
        if let sourceObjectID, let sourceState = context.world.targetState(for: sourceObjectID), sourceState.isValid {
            sourcePosition = sourceState.effectPosition
        }

        if isMasterAlive {
            if let onProcess, !onProcess(self, context) {
                retireMaster()
            } else {
                stateCnt += 1
                if duration > 0 && stateCnt >= duration {
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

    private func retireMaster() {
        isMasterAlive = false
        for primitive in primitives {
            primitive.detachMaster()
        }
    }
}
