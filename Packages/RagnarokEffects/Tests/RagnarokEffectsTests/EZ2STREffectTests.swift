//
//  EZ2STREffectTests.swift
//  RagnarokEffectsTests
//
//  Created by Leon Li on 2026/11/22.
//

import Foundation
import Metal
import RagnarokCore
import RagnarokFileFormats
import RagnarokResources
import simd
import Testing
@testable import RagnarokEffects

@MainActor
@Suite("EZ2STREffectCatalog & EZ2STREffect")
struct EZ2STREffectTests {
    private final class MockWorldContext: EffectWorldContext {
        var cameraWorldPosition: SIMD3<Float> = .zero
        var cameraYawDegrees: Float = 0
        var cameraPitchDegrees: Float = 0
        var terrainYInEffectSpace: Float = 0
        var targets: [EffectTargetID : EffectTargetState] = [:]
        var playedSounds: [String] = []
        var shakeCount: Int = 0

        func terrainHeight(atEffectX x: Float, effectZ z: Float) -> Float {
            terrainYInEffectSpace
        }

        func targetState(for targetID: EffectTargetID) -> EffectTargetState? {
            targets[targetID]
        }

        func playSound(named name: String, atWorldPosition position: SIMD3<Float>?, delay: TimeInterval) {
            playedSounds.append(name)
        }

        func shakeCamera(amplitude: Float, duration: TimeInterval, frequency: Float) {
            shakeCount += 1
        }

        func applyTargetModifier(_ modifier: EffectTargetModifier, to targetID: EffectTargetID) {}
        func spawnChildEffect(_ request: EffectSpawnRequest) {}
    }

    private static func makeBSONDocument(_ build: (inout Data) -> Void) -> Data {
        var body = Data()
        build(&body)
        body.append(0)
        var result = Data()
        var length = Int32(4 + body.count).littleEndian
        withUnsafeBytes(of: &length) { result.append(contentsOf: $0) }
        result.append(body)
        return result
    }

    private static func appendCString(_ string: String, to data: inout Data) {
        data.append(contentsOf: string.utf8)
        data.append(0)
    }

    private static func appendString(key: String, value: String, to data: inout Data) {
        data.append(0x02)
        appendCString(key, to: &data)
        let utf8 = Data(value.utf8)
        var length = Int32(utf8.count + 1).littleEndian
        withUnsafeBytes(of: &length) { data.append(contentsOf: $0) }
        data.append(utf8)
        data.append(0)
    }

    private static func appendDouble(key: String, value: Double, to data: inout Data) {
        data.append(0x01)
        appendCString(key, to: &data)
        var bits = value.bitPattern.littleEndian
        withUnsafeBytes(of: &bits) { data.append(contentsOf: $0) }
    }

    private static func appendBool(key: String, value: Bool, to data: inout Data) {
        data.append(0x08)
        appendCString(key, to: &data)
        data.append(value ? 1 : 0)
    }

    private static func appendInt32(key: String, value: Int32, to data: inout Data) {
        data.append(0x10)
        appendCString(key, to: &data)
        var little = value.littleEndian
        withUnsafeBytes(of: &little) { data.append(contentsOf: $0) }
    }

    private static func appendDocument(key: String, document: Data, to data: inout Data) {
        data.append(0x03)
        appendCString(key, to: &data)
        data.append(document)
    }

    @Test("EZ2STREffectCatalog sorts keys lexicographically, skips empty FilePath, and assigns 10000+ IDs")
    func catalogParsingAndIDAssignment() throws {
        let entryB = Self.makeBSONDocument { data in
            Self.appendString(key: "FilePath", value: "new_fx\\beta.str", to: &data)
            Self.appendDouble(key: "PosX", value: 10, to: &data)
            Self.appendDouble(key: "PosY", value: -25, to: &data)
            Self.appendBool(key: "IsInfinite", value: true, to: &data)
            Self.appendBool(key: "IsFloor", value: true, to: &data)
            Self.appendString(key: "SoundPath", value: "effect\\beta.wav", to: &data)
            Self.appendBool(key: "IsSoundLoop", value: true, to: &data)
            Self.appendInt32(key: "QuakeDelay", value: 12, to: &data)
            Self.appendInt32(key: "StartDelayTime", value: 32, to: &data)
            Self.appendBool(key: "IsToGround", value: true, to: &data)
        }
        let entryEmpty = Self.makeBSONDocument { data in
            Self.appendString(key: "FilePath", value: "", to: &data)
        }
        let entryA = Self.makeBSONDocument { data in
            Self.appendString(key: "FilePath", value: "new_fx\\alpha.str", to: &data)
            Self.appendBool(key: "IsAboveUI", value: true, to: &data)
        }
        let table = Self.makeBSONDocument { data in
            Self.appendDocument(key: "Zeta", document: entryB, to: &data)
            Self.appendDocument(key: "Empty", document: entryEmpty, to: &data)
            Self.appendDocument(key: "Alpha", document: entryA, to: &data)
        }
        let root = Self.makeBSONDocument { data in
            Self.appendDocument(key: "EZ2STREffect", document: table, to: &data)
        }

        let catalog = try EZ2STREffectCatalog(data: root)
        #expect(catalog.entries.count == 2)
        #expect(catalog.effectIDs == [EffectID(rawValue: 10_000), EffectID(rawValue: 10_001)])

        let alpha = catalog.entry(for: EffectID(rawValue: 10_000))
        #expect(alpha?.key == "alpha")
        #expect(alpha?.filePath == "new_fx\\alpha.str")
        #expect(alpha?.isAboveUI == true)
        #expect(catalog.effectID(named: "ALPHA") == EffectID(rawValue: 10_000))

        let zeta = catalog.entry(for: EffectID(rawValue: 10_001))
        #expect(zeta?.key == "zeta")
        #expect(zeta?.offsetX == 10)
        #expect(zeta?.offsetY == -25)
        #expect(zeta?.isInfinite == true)
        #expect(zeta?.isFloor == true)
        #expect(zeta?.soundPath == "effect\\beta.wav")
        #expect(zeta?.isSoundLoop == true)
        #expect(zeta?.quakeDelay == 12)
        #expect(zeta?.startDelayTime == 32)
        #expect(zeta?.isToGround == true)
    }

    @Test("EZ2STREffect honors render modes, delay, sound, quake, ground snap, and fade-out time limit")
    func effectExRuntimeBehavior() {
        let entry = EZ2STREffectCatalog.Entry(
            id: 0,
            key: "sample",
            filePath: "sample.str",
            offsetX: 5,
            offsetY: -10,
            isInfinite: false,
            isFloor: true,
            soundPath: "effect\\sample.wav",
            quakeDelay: 4,
            startDelayTime: 32,
            isToGround: true
        )

        let world = MockWorldContext()
        world.terrainYInEffectSpace = EffectSpace.toEffectHeight(3.5)

        let manager = EffectManager()
        let effect = EZ2STREffect(
            request: EffectSpawnRequest(effectID: entry.effectID, worldPosition: [2, 0, -4]),
            entry: entry
        )
        #expect(effect.renderMode == .ground)
        #expect(effect.transform.offset == SIMD2<Float>(5, -10))

        manager.registerParticleEffect(for: entry.effectID) { _, _ in effect }
        manager.spawn(EffectSpawnRequest(effectID: entry.effectID, worldPosition: [2, 0, -4]))

        // startDelayTime = 32ms -> frameStep = 2 -> sound triggers at eventFrame == 3, quake at 4
        for _ in 0..<5 {
            manager.stepOneTick(world: world)
        }
        #expect(world.playedSounds == ["effect\\sample.wav"])
        #expect(world.shakeCount == 1)
        #expect(abs(effect.worldPosition.y - 3.5) < 0.001)

        // Enable fade-out time limit: alpha drops 0.05 per tick -> expires in 20 ticks
        effect.enableTimeLimit()
        for _ in 0..<20 {
            manager.stepOneTick(world: world)
        }
        #expect(!effect.isAlive)
        #expect(!manager.hasEffects)
    }

    @Test("EZ2STREffectCatalog loads from ResourceManager and EffectManager spawns ID >= 10000")
    func catalogLoadAndManagerIntegration() async throws {
        let entry = Self.makeBSONDocument { data in
            Self.appendString(key: "FilePath", value: "new_fx\\custom.str", to: &data)
        }
        let table = Self.makeBSONDocument { data in
            Self.appendDocument(key: "Custom_Skill", document: entry, to: &data)
        }
        let bsonData = Self.makeBSONDocument { data in
            Self.appendDocument(key: "EZ2STREffect", document: table, to: &data)
        }

        struct StaticBSONProvider: ResourceProvider {
            let bsonData: Data
            func contentsOfResource(at path: ResourcePath) async throws -> Data {
                if path.components == EZ2STREffectCatalog.resourcePath.components {
                    return bsonData
                }
                throw ResourceError.resourceNotFound(path)
            }
        }

        let resourceManager = ResourceManager(resourceProvider: StaticBSONProvider(bsonData: bsonData))
        let loaded = await EZ2STREffectCatalog.load(from: resourceManager)
        #expect(loaded?.entries.count == 1)

        let manager = EffectManager(ez2strEffectCatalog: loaded)
        let bsonID = EffectID(rawValue: 10_000)
        #expect(manager.supports(bsonID))
        #expect(manager.supportedEffectIDs.contains(bsonID))

        let spawnedID = manager.spawn(EffectSpawnRequest(effectID: bsonID, worldPosition: .zero))
        #expect(spawnedID != nil)
        #expect(manager.activeEffects.first is EZ2STREffect)
    }

    @Test("Looping EZ2STREffect reads request.duration and expires after lifetimeTicks")
    func loopingBSONEffectExpiresAtRequestedDuration() {
        let entry = EZ2STREffectCatalog.Entry(
            id: 0,
            key: "looping_sample",
            filePath: "looping.str",
            isInfinite: true
        )
        let world = MockWorldContext()
        let context = EffectTickContext(
            world: world,
            assets: nil,
            currentTick: 1,
            usesMinimalEffects: false,
            onSpawnChild: { _ in }
        )

        let effect = EZ2STREffect(
            request: EffectSpawnRequest(
                effectID: entry.effectID,
                worldPosition: .zero,
                duration: 5.0 / EffectManager.tickRate
            ),
            entry: entry
        )
        #expect(effect.isLooping)
        #expect(effect.lifetimeTicks == 5)

        for _ in 0..<5 {
            effect.tick(context: context)
            #expect(effect.isAlive)
        }

        effect.tick(context: context)
        #expect(!effect.isAlive)
        #expect(effect.isFinished)
        #expect(effect.elapsedTicks == 5)
    }
}
