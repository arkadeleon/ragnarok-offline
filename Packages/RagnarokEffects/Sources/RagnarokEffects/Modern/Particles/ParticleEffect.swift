//
//  ParticleEffect.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/27.
//

import Foundation
import RagnarokRendering
import simd

/// Timed audio or camera shake event fired on a specific frame of a `ParticleEffect`.
public struct ParticleEffectEvent: Sendable, Equatable {
    public enum Kind: Sendable, Equatable {
        case sound
        case quake
    }

    public var kind: Kind
    public var frame: Int
    public var argument: Float
    public var text: String

    public init(kind: Kind, frame: Int, argument: Float = 0, text: String = "") {
        self.kind = kind
        self.frame = frame
        self.argument = argument
        self.text = text
    }
}

/// Base class for modern particle-driven effects supporting quad particles, sprite particles, and STR particles.
@MainActor
open class ParticleEffect: EffectPrimitiveRenderable, STREffectRenderable {
    public let id: UUID
    public let effectID: EffectID
    public let ownerObjectID: EffectTargetID?
    public let targetObjectID: EffectTargetID?
    public let sourceObjectID: EffectTargetID?
    public let attachmentKey: EffectAttachmentKey
    public let spawnRequest: EffectSpawnRequest

    /// Effect-space position (`1 GAT cell = 5.0`, Y-down, Z-inverted).
    public var position: SIMD3<Float>

    /// Effect-space direction vector.
    public var direction: SIMD3<Float>

    public var frame: Int = 0
    public var effectLifetime: Int = 60
    public var effectArgument: Int = 1
    public var effectLevel: Int = -1
    public var range: Float = 130
    public var outsideRange: Bool = false
    public var retained: Bool = false
    public var emissionStopped: Bool = false
    public var forceRender: Bool = false
    public var headAttached: Bool = false
    public var heights: [Float] = Array(repeating: 0, count: 21)
    public var events: [ParticleEffectEvent] = []

    private var hasOpened: Bool = false
    private var isStopped: Bool = false
    private var lastActorExists: Bool = true
    private weak var lastAssets: EffectAssetStore?

    public required init(id: UUID = UUID(), request: EffectSpawnRequest) {
        self.id = id
        self.effectID = request.effectID
        self.ownerObjectID = request.ownerObjectID
        self.targetObjectID = request.targetObjectID
        self.sourceObjectID = request.sourceObjectID
        self.attachmentKey = request.attachmentKey
        self.spawnRequest = request
        self.position = request.effectPosition
        self.direction = request.direction.map(EffectSpace.toEffectVector) ?? .zero
        if request.level != 0 {
            self.effectLevel = request.level
        }
        if let duration = request.duration, duration > 0 {
            self.effectLifetime = max(1, Int((duration * EffectManager.tickRate).rounded()))
        }
    }

    public var isFinished: Bool {
        frame >= effectLifetime
    }

    public var actorExists: Bool {
        ownerObjectID == nil || lastActorExists
    }

    public var isAlive: Bool {
        !isStopped && evaluateIsAlive()
    }

    open func evaluateIsAlive() -> Bool {
        actorExists
    }

    open func open(context: EffectTickContext) {
    }

    open func close() {
    }

    open func onProcess(context: EffectTickContext) {
    }

    open func collectParticles(
        into collector: inout EffectPrimitiveBatchCollector,
        fog: Fog,
        modelMatrix: simd_float4x4,
        world: any EffectWorldContext,
        assets: EffectAssetStore?
    ) {
    }

    open func collectSTRPayloads(
        fog: Fog,
        modelMatrix: simd_float4x4,
        world: any EffectWorldContext,
        assets: EffectAssetStore?
    ) -> [STREffectRenderer.RenderPayload] {
        []
    }

    public func tick(context: EffectTickContext) {
        guard !isStopped else {
            return
        }

        lastAssets = context.assets

        if !hasOpened {
            syncOwnerState(world: context.world)
            hasOpened = true
            open(context: context)
        } else {
            syncOwnerState(world: context.world)
        }

        checkRange(world: context.world)

        if !outsideRange {
            dispatchEvents(forFrame: frame, world: context.world)
        }

        onProcess(context: context)
        frame += 1
    }

    public func stop() {
        guard !isStopped else {
            return
        }
        isStopped = true
        close()
    }

    public func collectPrimitiveBatches(
        into collector: inout EffectPrimitiveBatchCollector,
        fog: Fog,
        modelMatrix: simd_float4x4,
        world: any EffectWorldContext
    ) {
        guard isAlive, !outsideRange || forceRender else {
            return
        }
        collectParticles(
            into: &collector,
            fog: fog,
            modelMatrix: modelMatrix,
            world: world,
            assets: lastAssets
        )
    }

    public func makeSTRRenderPayloads(
        fog: Fog,
        modelMatrix: simd_float4x4,
        world: any EffectWorldContext
    ) -> [STREffectRenderer.RenderPayload] {
        guard isAlive, !outsideRange || forceRender else {
            return []
        }
        return collectSTRPayloads(
            fog: fog,
            modelMatrix: modelMatrix,
            world: world,
            assets: lastAssets
        )
    }

    private func syncOwnerState(world: any EffectWorldContext) {
        guard let ownerObjectID else {
            lastActorExists = true
            return
        }
        if let state = world.targetState(for: ownerObjectID) {
            lastActorExists = state.isValid
            position = state.effectPosition
        } else {
            lastActorExists = false
        }
    }

    private func checkRange(world: any EffectWorldContext) {
        outsideRange = !world.isWithinRange(ofEffectPosition: position, maxDistance: range)
    }

    private func dispatchEvents(forFrame currentFrame: Int, world: any EffectWorldContext) {
        guard !events.isEmpty else {
            return
        }
        for event in events where event.frame == currentFrame {
            switch event.kind {
            case .sound:
                var soundEffectPosition = position
                soundEffectPosition.y += event.argument
                world.playSound(
                    named: event.text,
                    atWorldPosition: EffectSpace.toWorldPosition(soundEffectPosition),
                    delay: 0
                )
            case .quake:
                world.shakeCamera(amplitude: 0.4, duration: 0.3, frequency: 30)
            }
        }
    }
}
