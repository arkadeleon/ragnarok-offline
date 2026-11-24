//
//  RagEffectSTRTests.swift
//  RagnarokEffectsTests
//
//  Created by Leon Li on 2026/11/21.
//

import Foundation
import Metal
import RagnarokCore
import RagnarokFileFormats
import RagnarokRendering
import simd
import Testing
@testable import RagnarokEffects

@MainActor
@Suite("RagEffect STR Playback & Definitions")
struct RagEffectSTRTests {
    private final class RecordingWorldContext: EffectWorldContext {
        var cameraWorldPosition: SIMD3<Float> = .zero
        var cameraYawDegrees: Float = 0
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
        var uv: SIMD8<Float> = [0, 0, 1, 1, 0, 0, 1, 1]
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

    @Test("STREffectPlaybackState completes when a layer ends with same-frame base and delta keyframes")
    func playbackStateCompletesOnTrailingSameFrameKeyframes() throws {
        let str = try Self.makeSTR(layers: [
            (
                textures: ["tex0.bmp"],
                keyframes: [
                    SyntheticKeyframe(frameIndex: 0, type: 0, position: [100, 200], textureIndex: 0),
                    SyntheticKeyframe(frameIndex: 0, type: 1, position: [5, -2], rawColor: [0, 0, 0, 0]),
                ]
            ),
        ])

        var playbackState = STREffectPlaybackState(loopLimit: 0)

        // Frame 0: applies type 0 base keyframe and advances cursor to the trailing same-frame type 1 keyframe
        #expect(playbackState.step(str: str) == true)
        var frame = playbackState.makeFrame(for: str)
        #expect(frame.sprites.count == 1)
        #expect(frame.sprites[0].position == SIMD2<Float>(100, 200))

        // Frame 1: applies the trailing type 1 keyframe and marks the layer complete
        #expect(playbackState.step(str: str) == true)
        frame = playbackState.makeFrame(for: str)
        #expect(frame.sprites.count == 1)
        #expect(frame.sprites[0].position == SIMD2<Float>(105, 198))
        #expect(playbackState.currentLayer == playbackState.endLayer)

        // Frame 2: playback finishes instead of looping forever
        #expect(playbackState.step(str: str) == false)
        #expect(playbackState.makeFrame(for: str).sprites.isEmpty)
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
        #expect(!manager.hasEffects)

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

    @Test("STREffectRenderer preserves keyframe UV sub-regions and scrolling offsets across all three render modes")
    func rendererAppliesKeyframeUVAcrossAllModes() throws {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            return
        }

        let renderer = try STREffectRenderer(device: device, configuration: .default)
        let sprite = STREffectAnimation.Sprite(
            uv: [0.5, 0.0, 0.5, 1.0, 0.0, 0.0, 0.0, 0.0],
            xy: [-180, 180, 180, -180, -180, -180, 180, 180],
            textureName: "split.bmp",
            position: [320, 240],
            angle: 0,
            color: [1, 1, 1, 1],
            sourceAlpha: 5,
            destinationAlpha: 6,
            multiTexturePreset: 0
        )

        let expectedUVs: [SIMD2<Float>] = [
            [0.5, 0.0],
            [1.0, 0.0],
            [0.5, 1.0],
            [1.0, 1.0],
        ]

        let quadVertices = renderer.makeQuadVertices(for: sprite)
        #expect(quadVertices.map(\.textureCoordinate) == expectedUVs)

        let groundVertices = renderer.makeGroundVertices(
            for: sprite,
            worldPosition: .zero,
            transform: .identity,
            terrainHeight: nil
        )
        #expect(groundVertices.map(\.textureCoordinate) == expectedUVs)

        // Verify scrolled UV offset (u + us > 1.0) is emitted verbatim
        let scrolledSprite = STREffectAnimation.Sprite(
            uv: [0.75, 0.25, 0.5, 0.5, 0.0, 0.0, 0.0, 0.0],
            xy: sprite.xy,
            textureName: "split.bmp",
            position: sprite.position,
            angle: 0,
            color: [1, 1, 1, 1],
            sourceAlpha: 5,
            destinationAlpha: 6,
            multiTexturePreset: 0
        )
        let expectedScrolledUVs: [SIMD2<Float>] = [
            [0.75, 0.25],
            [1.25, 0.25],
            [0.75, 0.75],
            [1.25, 0.75],
        ]
        #expect(renderer.makeQuadVertices(for: scrolledSprite).map(\.textureCoordinate) == expectedScrolledUVs)

        // Build a 4x4 texture: left half (x = 0, 1) solid red, right half (x = 2, 3) solid green
        let sourceDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rgba8Unorm,
            width: 4,
            height: 4,
            mipmapped: false
        )
        sourceDescriptor.usage = [.shaderRead]
        let splitTexture = try #require(device.makeTexture(descriptor: sourceDescriptor))
        var pixels: [UInt8] = []
        for _ in 0..<4 {
            for x in 0..<4 {
                if x < 2 {
                    pixels.append(contentsOf: [255, 0, 0, 255]) // left half: red
                } else {
                    pixels.append(contentsOf: [0, 255, 0, 255]) // right half: green
                }
            }
        }
        splitTexture.replace(
            region: MTLRegionMake2D(0, 0, 4, 4),
            mipmapLevel: 0,
            withBytes: pixels,
            bytesPerRow: 4 * 4
        )

        let targetSize = 32
        let colorDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: targetSize,
            height: targetSize,
            mipmapped: false
        )
        colorDescriptor.usage = [.renderTarget]
        colorDescriptor.storageMode = .shared
        let colorTarget = try #require(device.makeTexture(descriptor: colorDescriptor))

        let depthDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .depth32Float,
            width: targetSize,
            height: targetSize,
            mipmapped: false
        )
        depthDescriptor.usage = [.renderTarget]
        depthDescriptor.storageMode = .private
        let depthTarget = try #require(device.makeTexture(descriptor: depthDescriptor))

        let ortho = simd_float4x4(
            columns: (
                SIMD4<Float>(0.2, 0, 0, 0),
                SIMD4<Float>(0, 0.2, 0, 0),
                SIMD4<Float>(0, 0, -0.05, 0),
                SIMD4<Float>(0, 0, 0, 1)
            )
        )
        let billboardView = matrix_translate(matrix_identity_float4x4, [0, 0, -10])
        let groundView = simd_float4x4(
            columns: (
                SIMD4<Float>(1, 0, 0, 0),
                SIMD4<Float>(0, 0, 1, 0),
                SIMD4<Float>(0, -1, 0, 0),
                SIMD4<Float>(0, 0, -10, 1)
            )
        )
        let billboardCamera = RenderCamera(
            viewMatrix: billboardView,
            projectionMatrix: ortho,
            position: [0, 0, 10]
        )
        let groundCamera = RenderCamera(
            viewMatrix: groundView,
            projectionMatrix: ortho,
            position: [0, 10, 0]
        )
        let screenCamera = RenderCamera(
            viewMatrix: matrix_identity_float4x4,
            projectionMatrix: matrix_identity_float4x4,
            position: .zero
        )

        let cases: [(STREffectRenderMode, RenderCamera)] = [
            (.billboard, billboardCamera),
            (.ground, groundCamera),
            (.screen, screenCamera),
        ]

        let frame = STREffectAnimation.Frame(sprites: [sprite])
        let textures: [String : any MTLTexture] = ["split.bmp": splitTexture]
        let fog = Fog()

        for (mode, camera) in cases {
            let passDescriptor = MTLRenderPassDescriptor()
            passDescriptor.colorAttachments[0].texture = colorTarget
            passDescriptor.colorAttachments[0].loadAction = .clear
            passDescriptor.colorAttachments[0].storeAction = .store
            passDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
            passDescriptor.depthAttachment.texture = depthTarget
            passDescriptor.depthAttachment.loadAction = .clear
            passDescriptor.depthAttachment.storeAction = .dontCare
            passDescriptor.depthAttachment.clearDepth = 1.0

            let commandBuffer = try #require(commandQueue.makeCommandBuffer())
            let encoder = try #require(commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor))
            renderer.render(
                frame: frame,
                textures: textures,
                mode: mode,
                worldPosition: .zero,
                transform: .identity,
                fog: fog,
                modelMatrix: matrix_identity_float4x4,
                terrainHeight: nil,
                camera: camera,
                renderCommandEncoder: encoder
            )
            encoder.endEncoding()
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()

            // Read back center pixel (BGRA8Unorm)
            var bgra: [UInt8] = [0, 0, 0, 0]
            colorTarget.getBytes(
                &bgra,
                bytesPerRow: targetSize * 4,
                from: MTLRegionMake2D(targetSize / 2, targetSize / 2, 1, 1),
                mipmapLevel: 0
            )
            let blue = bgra[0]
            let green = bgra[1]
            let red = bgra[2]
            #expect(green > 200, "Expected green right-half sample in mode \(mode), got BGRA=\(bgra)")
            #expect(red < 20, "Expected no red left-half sample in mode \(mode), got BGRA=\(bgra)")
            #expect(blue < 20, "Expected no blue channel in mode \(mode), got BGRA=\(bgra)")
        }
    }

    @Test("STREffectRenderer uses (320, 240) origin for screen/billboard while preserving Classic yOffset")
    func rendererUses240VerticalOriginAndClassicOffset() throws {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            return
        }

        let renderer = try STREffectRenderer(device: device, configuration: .default)
        let centeredSprite = STREffectAnimation.Sprite(
            uv: [0, 0, 1, 1, 0, 0, 1, 1],
            xy: [-16, 16, 16, -16, -16, -16, 16, 16],
            textureName: "white.bmp",
            position: [320, 240],
            angle: 0,
            color: [1, 1, 1, 1],
            sourceAlpha: 5,
            destinationAlpha: 6,
            multiTexturePreset: 0
        )

        // Modern default (zero offset, scale 1) lands directly on anchor (0, 0)
        #expect(renderer.makeSpriteOffset(for: centeredSprite, transform: .identity) == .zero)

        // Classic default (yOffset = -80) produces net -80 offset without double-shifting
        let classicTransform = STREffectTransform(offset: SIMD2<Float>(0, -80))
        #expect(renderer.makeSpriteOffset(for: centeredSprite, transform: classicTransform) == SIMD2<Float>(0, -80))

        // Offscreen screen-mode render: a small 32x32 design-pixel quad at (320, 240) must hit the viewport center
        let sourceDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rgba8Unorm,
            width: 2,
            height: 2,
            mipmapped: false
        )
        sourceDescriptor.usage = [.shaderRead]
        let whiteTexture = try #require(device.makeTexture(descriptor: sourceDescriptor))
        let whitePixels = [UInt8](repeating: 255, count: 2 * 2 * 4)
        whiteTexture.replace(
            region: MTLRegionMake2D(0, 0, 2, 2),
            mipmapLevel: 0,
            withBytes: whitePixels,
            bytesPerRow: 2 * 4
        )

        let targetSize = 32
        let colorDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: targetSize,
            height: targetSize,
            mipmapped: false
        )
        colorDescriptor.usage = [.renderTarget]
        colorDescriptor.storageMode = .shared
        let colorTarget = try #require(device.makeTexture(descriptor: colorDescriptor))

        let depthDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .depth32Float,
            width: targetSize,
            height: targetSize,
            mipmapped: false
        )
        depthDescriptor.usage = [.renderTarget]
        depthDescriptor.storageMode = .private
        let depthTarget = try #require(device.makeTexture(descriptor: depthDescriptor))

        let passDescriptor = MTLRenderPassDescriptor()
        passDescriptor.colorAttachments[0].texture = colorTarget
        passDescriptor.colorAttachments[0].loadAction = .clear
        passDescriptor.colorAttachments[0].storeAction = .store
        passDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        passDescriptor.depthAttachment.texture = depthTarget
        passDescriptor.depthAttachment.loadAction = .clear
        passDescriptor.depthAttachment.storeAction = .dontCare
        passDescriptor.depthAttachment.clearDepth = 1.0

        let screenCamera = RenderCamera(
            viewMatrix: matrix_identity_float4x4,
            projectionMatrix: matrix_identity_float4x4,
            position: .zero
        )
        let commandBuffer = try #require(commandQueue.makeCommandBuffer())
        let encoder = try #require(commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor))
        renderer.render(
            frame: STREffectAnimation.Frame(sprites: [centeredSprite]),
            textures: ["white.bmp": whiteTexture],
            mode: .screen,
            worldPosition: .zero,
            transform: .identity,
            fog: Fog(),
            modelMatrix: matrix_identity_float4x4,
            terrainHeight: nil,
            camera: screenCamera,
            renderCommandEncoder: encoder
        )
        encoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        var bgra: [UInt8] = [0, 0, 0, 0]
        colorTarget.getBytes(
            &bgra,
            bytesPerRow: targetSize * 4,
            from: MTLRegionMake2D(targetSize / 2, targetSize / 2, 1, 1),
            mipmapLevel: 0
        )
        #expect(bgra[0] > 200 && bgra[1] > 200 && bgra[2] > 200, "Expected centered screen-mode quad at (320, 240) to hit viewport center, got BGRA=\(bgra)")
    }

    @Test("STREffectRenderer ground vertices clamp cliffs symmetrically relative to center height")
    func strEffectRendererGroundCliffClamping() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            return
        }

        let renderer = try STREffectRenderer(device: device, configuration: .default)
        let sprite = STREffectAnimation.Sprite(
            uv: [0, 0, 1, 1, 0, 0, 0, 0],
            xy: [-35, 35, 35, -35, -35, -35, 35, 35],
            textureName: "ground.bmp",
            position: [320, 240],
            angle: 0,
            color: [1, 1, 1, 1],
            sourceAlpha: 5,
            destinationAlpha: 6,
            multiTexturePreset: 0
        )

        let groundVertices = renderer.makeGroundVertices(
            for: sprite,
            worldPosition: .zero,
            transform: .identity,
            terrainHeight: { worldX, worldZ in
                if worldX < 0 && worldZ < 0 {
                    return -5.0
                }
                if worldX > 0 && worldZ > 0 {
                    return 5.0
                }
                return 0.0
            }
        )

        // Center height is 0.0 + 0.08 = 0.08; cliff clamp is +/- 1.0 -> [-0.92, 1.08].
        #expect(abs(groundVertices[0].position.y - (-0.92)) < 0.001)
        #expect(abs(groundVertices[1].position.y - 0.08) < 0.001)
        #expect(abs(groundVertices[2].position.y - 0.08) < 0.001)
        #expect(abs(groundVertices[3].position.y - 1.08) < 0.001)
    }
}
