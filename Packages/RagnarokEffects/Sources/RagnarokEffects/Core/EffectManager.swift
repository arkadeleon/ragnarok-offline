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

    public nonisolated static var supportedRawEffectIDs: [Int] {
        let screenEffectIDs = EZ2STRScreenEffectDefinition.definitions.map(\.effectID.rawValue)
        let ragEffectIDs = RagSTREffectDefinition.definitions.map(\.effectID.rawValue)
        return Array(Set(screenEffectIDs).union(ragEffectIDs)).sorted()
    }

    public nonisolated static func supports(rawEffectID: Int) -> Bool {
        guard let effectID = EffectID(rawValue: rawEffectID) else {
            return false
        }
        return supports(effectID)
    }

    public nonisolated static func supports(_ effectID: EffectID) -> Bool {
        EZ2STRScreenEffectDefinition.definition(for: effectID) != nil
            || RagSTREffectDefinition.definition(for: effectID) != nil
    }

    public let assetStore: EffectAssetStore?
    public var ez2strEffectCatalog: EZ2STREffectCatalog?
    public var usesMinimalEffects: Bool

    public private(set) var currentTick: Int = 0
    public private(set) var activeEffects: [any EffectInstance] = []

    private var pendingSpawns: [PendingSpawn] = []
    private var particleEffectBuilders: [Int : EffectBuilder] = [:]
    private var ragEffectBuilders: [Int : EffectBuilder] = [:]

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

    func registerParticleEffect(for rawEffectID: Int, builder: @escaping EffectBuilder) {
        particleEffectBuilders[rawEffectID] = builder
    }

    func registerParticleEffect(for effectID: EffectID, builder: @escaping EffectBuilder) {
        particleEffectBuilders[effectID.rawValue] = builder
    }

    func registerRagEffect(for rawEffectID: Int, builder: @escaping EffectBuilder) {
        ragEffectBuilders[rawEffectID] = builder
    }

    func registerRagEffect(for effectID: EffectID, builder: @escaping EffectBuilder) {
        ragEffectBuilders[effectID.rawValue] = builder
    }

    public func supports(rawEffectID: Int) -> Bool {
        particleEffectBuilders[rawEffectID] != nil
            || ragEffectBuilders[rawEffectID] != nil
            || Self.supports(rawEffectID: rawEffectID)
            || ez2strEffectCatalog?.entry(forRawEffectID: rawEffectID) != nil
    }

    public func supports(_ effectID: EffectID) -> Bool {
        supports(rawEffectID: effectID.rawValue)
    }

    public var supportedRawEffectIDs: [Int] {
        Set(Self.supportedRawEffectIDs)
            .union(particleEffectBuilders.keys)
            .union(ragEffectBuilders.keys)
            .union(ez2strEffectCatalog?.rawEffectIDs ?? [])
            .sorted()
    }

    public var hasActiveEffects: Bool {
        !activeEffects.isEmpty || !pendingSpawns.isEmpty
    }

    public var activeEffectCount: Int {
        activeEffects.count + pendingSpawns.count
    }

    @discardableResult
    public func spawn(_ request: EffectSpawnRequest, id: UUID = UUID()) -> UUID? {
        guard supports(rawEffectID: request.rawEffectID) else {
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

    @discardableResult
    private func spawnImmediately(id: UUID, request: EffectSpawnRequest) -> UUID? {
        let effect: any EffectInstance
        if let builder = particleEffectBuilders[request.rawEffectID] {
            effect = builder(id, request)
        } else if let entry = ez2strEffectCatalog?.entry(forRawEffectID: request.rawEffectID) {
            effect = EZ2STREffect(id: id, request: request, entry: entry)
        } else if let effectID = request.effectID, let definition = EZ2STRScreenEffectDefinition.definition(for: effectID) {
            effect = EZ2STRScreenEffect(id: id, request: request, definition: definition, usesMinimalEffects: usesMinimalEffects)
        } else if let builder = ragEffectBuilders[request.rawEffectID] {
            effect = builder(id, request)
        } else if let effectID = request.effectID, let definition = RagSTREffectDefinition.definition(for: effectID) {
            effect = RagSTREffect(id: id, request: request, definition: definition, usesMinimalEffects: usesMinimalEffects)
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
