//
//  EffectManager.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/20.
//

import Foundation
import RagnarokRendering
import simd

@MainActor
public final class EffectManager {
    public typealias EffectBuilder = (UUID, EffectSpawnRequest) -> any EffectInstance

    private struct PendingSpawn {
        let id: UUID
        let request: EffectSpawnRequest
        var remainingTicks: Int
    }

    public static let tickRate: Double = 60.0
    public static let tickDuration: TimeInterval = 1.0 / tickRate
    public static let maxTicksPerUpdate: Int = 4

    public nonisolated static var builtInEffectIDs: [EffectID] {
        let screenEffectIDs = EZ2STRScreenEffectDefinition.definitions.map(\.effectID)
        let ragEffectIDs = RagEffect.supportedEffectIDs
        return Array(Set(screenEffectIDs).union(ragEffectIDs)).sorted()
    }

    public nonisolated static func hasBuiltInDefinition(for effectID: EffectID) -> Bool {
        EZ2STRScreenEffectDefinition.definition(for: effectID) != nil
            || RagEffect.supports(effectID)
    }

    public let assetStore: EffectAssetStore?
    public var ez2strEffectCatalog: EZ2STREffectCatalog?
    public var usesMinimalEffects: Bool

    public private(set) var currentTick: Int = 0
    public private(set) var activeEffects: [any EffectInstance] = []

    private var pendingSpawns: [PendingSpawn] = []
    private var particleEffectBuilders: [EffectID : EffectBuilder] = [:]
    private var ragEffectBuilders: [EffectID : EffectBuilder] = [:]

    private var lastUpdateTime: TimeInterval?
    private var tickAccumulator: TimeInterval = 0

    public init(
        assetStore: EffectAssetStore? = nil,
        ez2strEffectCatalog: EZ2STREffectCatalog? = nil,
        usesMinimalEffects: Bool = false
    ) {
        self.assetStore = assetStore
        self.ez2strEffectCatalog = ez2strEffectCatalog
        self.usesMinimalEffects = usesMinimalEffects
    }

    func registerParticleEffect(for effectID: EffectID, builder: @escaping EffectBuilder) {
        particleEffectBuilders[effectID] = builder
    }

    func registerRagEffect(for effectID: EffectID, builder: @escaping EffectBuilder) {
        ragEffectBuilders[effectID] = builder
    }

    public func supports(_ effectID: EffectID) -> Bool {
        particleEffectBuilders[effectID] != nil
            || ragEffectBuilders[effectID] != nil
            || Self.hasBuiltInDefinition(for: effectID)
            || ez2strEffectCatalog?.entry(for: effectID) != nil
    }

    public var supportedEffectIDs: [EffectID] {
        Set(Self.builtInEffectIDs)
            .union(particleEffectBuilders.keys)
            .union(ragEffectBuilders.keys)
            .union(ez2strEffectCatalog?.effectIDs ?? [])
            .sorted()
    }

    public var hasEffects: Bool {
        !activeEffects.isEmpty || !pendingSpawns.isEmpty
    }

    public var effectCount: Int {
        activeEffects.count + pendingSpawns.count
    }

    public func contains(instanceID: UUID) -> Bool {
        activeEffects.contains { $0.id == instanceID }
            || pendingSpawns.contains { $0.id == instanceID }
    }

    @discardableResult
    public func spawn(_ request: EffectSpawnRequest, id: UUID = UUID()) -> UUID? {
        guard supports(request.effectID) else {
            return nil
        }

        if request.delay > 0 {
            let delayTicks = max(1, Int((request.delay * Self.tickRate).rounded()))
            let spawn = PendingSpawn(id: id, request: request, remainingTicks: delayTicks)
            pendingSpawns.append(spawn)
            return id
        }

        return spawnImmediately(id: id, request: request)
    }

    public func removeEffects(ownedBy ownerObjectID: EffectTargetID, key: EffectAttachmentKey? = nil) {
        pendingSpawns.removeAll {
            $0.request.ownerObjectID == ownerObjectID && (key == nil || $0.request.attachmentKey == key)
        }
        activeEffects.removeAll { effect in
            let matches = effect.ownerObjectID == ownerObjectID && (key == nil || effect.attachmentKey == key)
            if matches {
                effect.stop()
            }
            return matches
        }
    }

    public func removeEffect(instanceID: UUID) {
        pendingSpawns.removeAll {
            $0.id == instanceID
        }
        activeEffects.removeAll {
            guard $0.id == instanceID else {
                return false
            }
            $0.stop()
            return true
        }
    }

    public func removeAll() {
        pendingSpawns.removeAll()
        activeEffects.forEach {
            $0.stop()
        }
        activeEffects.removeAll()
        lastUpdateTime = nil
        tickAccumulator = 0
    }

    @discardableResult
    public func update(atTime time: TimeInterval, world: any EffectWorldContext) -> Int {
        guard let previousTime = lastUpdateTime else {
            lastUpdateTime = time
            return 0
        }
        lastUpdateTime = time
        return advance(deltaTime: max(0, time - previousTime), world: world)
    }

    @discardableResult
    public func advance(deltaTime: TimeInterval, world: any EffectWorldContext) -> Int {
        guard deltaTime > 0 else {
            return 0
        }

        let epsilon: TimeInterval = 1e-9
        tickAccumulator += deltaTime

        var ticks = 0
        while tickAccumulator + epsilon >= Self.tickDuration && ticks < Self.maxTicksPerUpdate {
            tickAccumulator = max(0, tickAccumulator - Self.tickDuration)
            stepOneTick(world: world)
            ticks += 1
        }

        if ticks == Self.maxTicksPerUpdate && tickAccumulator + epsilon >= Self.tickDuration {
            tickAccumulator = tickAccumulator.truncatingRemainder(dividingBy: Self.tickDuration)
        }

        return ticks
    }

    public func stepOneTick(world: any EffectWorldContext) {
        currentTick += 1
        processPendingSpawns()

        var childRequests: [EffectSpawnRequest] = []
        let context = EffectTickContext(
            world: world,
            assets: assetStore,
            currentTick: currentTick,
            usesMinimalEffects: usesMinimalEffects,
            onSpawnChild: {
                childRequests.append($0)
            }
        )

        for effect in activeEffects where effect.isAlive {
            effect.tick(context: context)
        }

        activeEffects.removeAll {
            !$0.isAlive
        }

        for childRequest in childRequests where spawn(childRequest) == nil {
            world.spawnChildEffect(childRequest)
        }
    }

    public func collectSTRPayloads(
        fog: Fog,
        modelMatrix: simd_float4x4 = matrix_identity_float4x4,
        world: any EffectWorldContext
    ) -> [STREffectRenderer.RenderPayload] {
        var payloads: [STREffectRenderer.RenderPayload] = []
        for effect in activeEffects {
            if let renderable = effect as? any STREffectRenderable {
                let strPayloads = renderable.makeSTRRenderPayloads(fog: fog, modelMatrix: modelMatrix, world: world)
                payloads.append(contentsOf: strPayloads)
            }
        }
        return payloads
    }

    public func collectPrimitivePayloads(
        fog: Fog,
        modelMatrix: simd_float4x4 = matrix_identity_float4x4,
        world: any EffectWorldContext
    ) -> [EffectPrimitiveBatchRenderer.RenderPayload] {
        var payloads: [EffectPrimitiveBatchRenderer.RenderPayload] = []
        for effect in activeEffects {
            if let renderable = effect as? any EffectPrimitiveRenderable {
                var collector = EffectPrimitiveBatchCollector(fog: fog, modelMatrix: modelMatrix)
                renderable.collectPrimitiveBatches(into: &collector, fog: fog, modelMatrix: modelMatrix, world: world)
                payloads.append(contentsOf: collector.batches)
            }
        }
        return payloads
    }

    @discardableResult
    private func spawnImmediately(id: UUID, request: EffectSpawnRequest) -> UUID? {
        let effect: any EffectInstance
        if let builder = particleEffectBuilders[request.effectID] {
            effect = builder(id, request)
        } else if let entry = ez2strEffectCatalog?.entry(for: request.effectID) {
            effect = EZ2STREffect(id: id, request: request, entry: entry)
        } else if let definition = EZ2STRScreenEffectDefinition.definition(for: request.effectID) {
            effect = EZ2STRScreenEffect(id: id, request: request, definition: definition)
        } else if let builder = ragEffectBuilders[request.effectID] {
            effect = builder(id, request)
        } else if let ragEffect = RagEffect.make(id: id, request: request, usesMinimalEffects: usesMinimalEffects) {
            effect = ragEffect
        } else {
            return nil
        }

        activeEffects.append(effect)
        return id
    }

    private func processPendingSpawns() {
        guard !pendingSpawns.isEmpty else {
            return
        }

        var readySpawns: [PendingSpawn] = []
        pendingSpawns = pendingSpawns.compactMap { pendingSpawn in
            var nextSpawn = pendingSpawn
            nextSpawn.remainingTicks -= 1
            if nextSpawn.remainingTicks <= 0 {
                readySpawns.append(nextSpawn)
                return nil
            }
            return nextSpawn
        }

        for spawn in readySpawns {
            _ = spawnImmediately(id: spawn.id, request: spawn.request)
        }
    }
}
