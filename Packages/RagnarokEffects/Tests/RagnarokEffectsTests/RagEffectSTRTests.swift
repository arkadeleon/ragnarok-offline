//
//  RagEffectSTRTests.swift
//  RagnarokEffectsTests
//
//  Created by Leon Li on 2026/11/21.
//

import Foundation
import RagnarokCore
import RagnarokFileFormats
import simd
import Testing
@testable import RagnarokEffects

@MainActor
@Suite("RagEffect STR Playback & Definitions")
struct RagEffectSTRTests {
    private final class RecordingWorldContext: EffectWorldContext {
        var cameraWorldPosition: SIMD3<Float> = .zero
        var targets: [EffectTargetID : EffectTargetState] = [:]
        var playedSounds: [(name: String, position: SIMD3<Float>?)] = []
        var shakeCount: Int = 0
        var appliedModifiers: [(targetID: EffectTargetID, modifier: EffectTargetModifier)] = []

        func terrainHeight(atEffectX x: Float, effectZ z: Float) -> Float {
            0
        }

        func targetState(for targetID: EffectTargetID) -> EffectTargetState? {
            targets[targetID]
        }

        func playSound(named name: String, atWorldPosition position: SIMD3<Float>?, delay: TimeInterval) {
            playedSounds.append((name, position))
        }

        func shakeCamera(amplitude: Float, duration: TimeInterval, frequency: Float) {
            shakeCount += 1
        }

        func applyTargetModifier(_ modifier: EffectTargetModifier, to targetID: EffectTargetID) {
            appliedModifiers.append((targetID, modifier))
        }

        func spawnChildEffect(_ request: EffectSpawnRequest) {}
    }

    private struct SyntheticKeyframe {
        var frameIndex: Int32
        var type: Int32
        var position: SIMD2<Float> = [320, 240]
        var uv: SIMD8<Float> = [0, 0, 1, 0, 1, 1, 0, 1]
        var xy: SIMD8<Float> = [-10, 10, 10, -10, -10, -10, 10, 10]
        var textureIndex: Float = 0
        var animationType: Int32 = 0
        var delay: Float = 0
        var rawAngle: Float = 0
        var rawColor: SIMD4<Float> = [255, 255, 255, 255]
        var sourceAlpha: Int32 = 5
        var destinationAlpha: Int32 = 6
        var multiTexturePreset: Int32 = 0
    }

    private static func makeSTR(
        fps: Int32 = 60,
        maxKeyframeIndex: Int32 = 10,
        layers: [(textures: [String], keyframes: [SyntheticKeyframe])]
    ) throws -> STR {
        var data = Data()

        func appendInt32(_ value: Int32) {
            var v = value.littleEndian
            withUnsafeBytes(of: &v) { data.append(contentsOf: $0) }
        }

        func appendFloat(_ value: Float) {
            var bits = value.bitPattern.littleEndian
            withUnsafeBytes(of: &bits) { data.append(contentsOf: $0) }
        }

        func appendFixedString(_ string: String, length: Int) {
            let raw = Data(string.utf8.prefix(length))
            data.append(raw)
            if raw.count < length {
                data.append(Data(repeating: 0, count: length - raw.count))
            }
        }

        data.append(contentsOf: "STRM".utf8)
        data.append(contentsOf: [1, 48, 0, 0]) // version 1.48 + 2 reserved bytes
        appendInt32(fps)
        appendInt32(maxKeyframeIndex)
        appendInt32(Int32(layers.count))
        data.append(Data(repeating: 0, count: 16))

        for layer in layers {
            appendInt32(Int32(layer.textures.count))
            for texture in layer.textures {
                appendFixedString(texture, length: 128)
            }
            appendInt32(Int32(layer.keyframes.count))
            for key in layer.keyframes {
                appendInt32(key.frameIndex)
                appendInt32(key.type)
                appendFloat(key.position.x)
                appendFloat(key.position.y)
                for i in 0..<8 { appendFloat(key.uv[i]) }
                for i in 0..<8 { appendFloat(key.xy[i]) }
                appendFloat(key.textureIndex)
                appendInt32(key.animationType)
                appendFloat(key.delay)
                appendFloat(key.rawAngle)
                appendFloat(key.rawColor.x)
                appendFloat(key.rawColor.y)
                appendFloat(key.rawColor.z)
                appendFloat(key.rawColor.w)
                appendInt32(key.sourceAlpha)
                appendInt32(key.destinationAlpha)
                appendInt32(key.multiTexturePreset)
            }
        }

        return try STR(data: data)
    }

    @Test("STREffectPlaybackState copies type-0 keyframes, accumulates type-1 deltas, and loops up to loopLimit")
    func playbackStateCopyMorphAndLoop() throws {
        let str = try Self.makeSTR(layers: [
            (
                textures: ["tex0.bmp", "tex1.bmp", "tex2.bmp"],
                keyframes: [
                    SyntheticKeyframe(frameIndex: 0, type: 0, position: [100, 200], textureIndex: 0),
                    SyntheticKeyframe(frameIndex: 0, type: 1, position: [5, -2], animationType: 3, delay: 1.0, rawColor: [0, 0, 0, 0]),
                    SyntheticKeyframe(frameIndex: 3, type: 0, position: [300, 400], textureIndex: 2),
                ]
            ),
        ])

        var playbackState = STREffectPlaybackState(loopLimit: 1)

        // Frame 0: type 0 copies initial transform and advances currentKey to the same-frame type 1 key
        #expect(playbackState.step(str: str) == true)
        var frame = playbackState.makeFrame(for: str)
        #expect(frame.sprites.count == 1)
        #expect(frame.sprites[0].position == SIMD2<Float>(100, 200))
        #expect(frame.sprites[0].textureName == "tex0.bmp")

        // Frame 1: type 1 adds position delta and advances textureIndex via anitype 3
        #expect(playbackState.step(str: str) == true)
        frame = playbackState.makeFrame(for: str)
        #expect(frame.sprites[0].position == SIMD2<Float>(105, 198))
        #expect(frame.sprites[0].textureName == "tex1.bmp")

        // Frame 2: type 1 accumulates again
        #expect(playbackState.step(str: str) == true)
        frame = playbackState.makeFrame(for: str)
        #expect(frame.sprites[0].position == SIMD2<Float>(110, 196))
        #expect(frame.sprites[0].textureName == "tex2.bmp")

        // Frame 3: reaches final keyframe (frameIndex == 3), marks layer complete
        #expect(playbackState.step(str: str) == true)
        frame = playbackState.makeFrame(for: str)
        #expect(frame.sprites[0].position == SIMD2<Float>(300, 400))
        #expect(frame.sprites[0].textureName == "tex2.bmp")

        // Next step triggers loop 1 (since loopLimit == 1), resets to frame 0
        #expect(playbackState.step(str: str) == true)
        #expect(playbackState.loopCount == 1)
        frame = playbackState.makeFrame(for: str)
        #expect(frame.sprites[0].position == SIMD2<Float>(100, 200))

        // Finish second pass (frames 1, 2, 3)
        #expect(playbackState.step(str: str) == true)
        #expect(playbackState.step(str: str) == true)
        #expect(playbackState.step(str: str) == true)

        // Exceeds loopLimit -> stops and clears drawn layers
        #expect(playbackState.step(str: str) == false)
        #expect(playbackState.makeFrame(for: str).sprites.isEmpty)
    }

    @Test("STREffectPlaybackState handles anitype 2 clamp and anitype 5 ping-pong")
    func playbackStateAnimationTypes() throws {
        let clampSTR = try Self.makeSTR(layers: [
            (
                textures: ["a.bmp", "b.bmp"],
                keyframes: [
                    SyntheticKeyframe(frameIndex: 0, type: 0, textureIndex: 0),
                    SyntheticKeyframe(frameIndex: 0, type: 1, animationType: 2, delay: 1.5, rawColor: [0, 0, 0, 0]),
                    SyntheticKeyframe(frameIndex: 4, type: 0, textureIndex: 1),
                ]
            ),
        ])

        var clampPlaybackState = STREffectPlaybackState()
        #expect(clampPlaybackState.step(str: clampSTR) == true)
        #expect(clampPlaybackState.step(str: clampSTR) == true)
        #expect(clampPlaybackState.transforms[0].textureIndex == 1.5)
        #expect(clampPlaybackState.step(str: clampSTR) == true)
        #expect(clampPlaybackState.transforms[0].textureIndex == 1.0)

        let pingPongSTR = try Self.makeSTR(layers: [
            (
                textures: ["f0.bmp", "f1.bmp", "f2.bmp"],
                keyframes: [
                    SyntheticKeyframe(frameIndex: 0, type: 0, textureIndex: 0),
                    SyntheticKeyframe(frameIndex: 0, type: 1, animationType: 5, delay: 1.0, rawColor: [0, 0, 0, 0]),
                    SyntheticKeyframe(frameIndex: 5, type: 0, textureIndex: 0),
                ]
            ),
        ])

        var pingPongPlaybackState = STREffectPlaybackState()
        #expect(pingPongPlaybackState.step(str: pingPongSTR) == true) // frame 0 -> 0
        #expect(pingPongPlaybackState.step(str: pingPongSTR) == true) // elapsed 1 -> 1
        #expect(pingPongPlaybackState.makeFrame(for: pingPongSTR).sprites[0].textureName == "f1.bmp")
        #expect(pingPongPlaybackState.step(str: pingPongSTR) == true) // elapsed 2, prev 1 -> 3 -> turns=1 -> 2-(3-2)=1
        #expect(pingPongPlaybackState.makeFrame(for: pingPongSTR).sprites[0].textureName == "f1.bmp")
    }

    @Test("RagSTREffectDefinition covers all 199 pure-STR entries with expected overrides")
    func definitionCoverageAndResolution() {
        #expect(RagSTREffectDefinition.definitions.count == 199)
        #expect(RagSTREffectDefinition.definitionsByEffectID.count == 199)

        let cure = RagSTREffectDefinition.definition(for: .ef_cure)
        #expect(cure?.resolveSTRPath(usesMinimalEffects: false) == "Cure.str")
        #expect(cure?.resolveSTRPath(usesMinimalEffects: true) == "cure_min.str")

        let windHit = RagSTREffectDefinition.definition(for: .ef_windhit)
        #expect(windHit?.resolveSTRPath(randomValue: { _ in 2 }) == "WindHit2.str")

        #expect(RagSTREffectDefinition.definition(for: .ef_shieldcharge)?.yOffset == 0)
        #expect(RagSTREffectDefinition.definition(for: .ef_devotion)?.yOffset == -20)
        #expect(RagSTREffectDefinition.definition(for: .ef_gc_darkcrow)?.yOffset == 40)
        #expect(RagSTREffectDefinition.definition(for: .ef_gc_darkcrow)?.loopLimit == 9999)
        #expect(RagSTREffectDefinition.definition(for: .ef_duststorm)?.loopLimit == 10)
        #expect(RagSTREffectDefinition.definition(for: .ef_shockwave)?.restartsOnEnd == true)
        #expect(RagSTREffectDefinition.definition(for: .ef_shockwave)?.endsWhenSTRCompletes == false)
        #expect(RagSTREffectDefinition.definition(for: .ef_suicide)?.usesTargetPosition == true)
        #expect(RagSTREffectDefinition.definition(for: .ef_potion1)?.strPath == K2L("빨간포션.str"))

        let lord = RagSTREffectDefinition.definition(for: .ef_lord)
        #expect(lord?.endsWhenSTRCompletes == true)
        #expect(lord?.cameraShakeTicks == [50, 100, 150, 200, 250])
        #expect(lord?.sounds.filter { $0.tick == 0 }.count == 2)

        // Hybrid STR+Prim effects remain excluded until Step 5.3
        #expect(RagSTREffectDefinition.definition(for: .ef_stormgust) == nil)
        #expect(RagSTREffectDefinition.definition(for: .ef_aspersio) == nil)
    }

    @Test("EffectManager registers all pure-STR effects and drives timed sounds, shakes, tints, and target tracking")
    func managerDefaultRegistrationAndRuntimeEvents() {
        let manager = EffectManager()
        let world = RecordingWorldContext()

        #expect(manager.supports(.ef_thunderstorm))
        #expect(manager.supports(.ef_meteorstorm))
        #expect(manager.supports(.ef_lord))
        #expect(manager.supports(.ef_suicide))
        #expect(!manager.supports(.ef_stormgust))

        // MeteorStorm: sound at tick 0, camera shake at tick 40
        manager.spawn(EffectSpawnRequest(effectID: .ef_meteorstorm, worldPosition: [10, 0, -20], duration: 45.0 / 60.0))
        for _ in 0..<41 {
            manager.stepOneTick(world: world)
        }
        #expect(world.playedSounds.map(\.name) == ["effect\\wizard_meteor.wav"])
        #expect(world.shakeCount == 1)

        // Expire MeteorStorm after 45 ticks
        for _ in 0..<4 {
            manager.stepOneTick(world: world)
        }
        #expect(!manager.hasActiveEffects)

        // LKConcentration: constant tint + sound at tick 0
        let ownerID: EffectTargetID = 42
        let targetID: EffectTargetID = 99
        world.targets[ownerID] = EffectTargetState(objectID: ownerID, worldPosition: [1, 0, 2])
        world.targets[targetID] = EffectTargetState(objectID: targetID, worldPosition: [8, 0, -4])

        manager.spawn(EffectSpawnRequest(effectID: .ef_lkconcentration, worldPosition: .zero, ownerObjectID: ownerID, duration: 2.0 / 60.0))
        manager.stepOneTick(world: world)
        #expect(world.appliedModifiers.contains { $0.targetID == ownerID })

        // Suicide: tracks targetObjectID position when usesTargetPosition == true
        manager.spawn(EffectSpawnRequest(effectID: .ef_suicide, worldPosition: .zero, ownerObjectID: ownerID, targetObjectID: targetID, duration: 2.0 / 60.0))
        manager.stepOneTick(world: world)
        let suicide = manager.activeEffects.compactMap { $0 as? RagSTREffect }.first { $0.effectID == .ef_suicide }
        #expect(suicide?.worldPosition == SIMD3<Float>(8, 0, -4))
    }
}
