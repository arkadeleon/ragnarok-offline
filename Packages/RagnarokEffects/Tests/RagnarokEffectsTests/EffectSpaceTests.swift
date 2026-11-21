//
//  EffectSpaceTests.swift
//  RagnarokEffectsTests
//
//  Created by Leon Li on 2026/11/20.
//

import Foundation
import simd
import Testing
@testable import RagnarokEffects

@Suite("EffectSpace")
struct EffectSpaceTests {
    private func approxEqual(_ a: Float, _ b: Float, tolerance: Float = 1e-4) -> Bool {
        abs(a - b) <= tolerance
    }

    private func approxEqual(_ a: SIMD3<Float>, _ b: SIMD3<Float>, tolerance: Float = 1e-4) -> Bool {
        approxEqual(a.x, b.x, tolerance: tolerance)
            && approxEqual(a.y, b.y, tolerance: tolerance)
            && approxEqual(a.z, b.z, tolerance: tolerance)
    }

    @Test("World and effect space coordinate round-trip")
    func coordinateRoundTrip() {
        let world = SIMD3<Float>(12.5, 3.2, -7.4)
        let effect = EffectSpace.toEffectPosition(world)

        #expect(approxEqual(effect, SIMD3<Float>(62.5, -16.0, 37.0)))
        #expect(approxEqual(EffectSpace.toWorldPosition(effect), world))

        #expect(approxEqual(EffectSpace.toEffectHeight(4.0), -20.0))
        #expect(approxEqual(EffectSpace.toWorldHeight(-20.0), 4.0))

        #expect(approxEqual(EffectSpace.toEffectDistance(6.0), 30.0))
        #expect(approxEqual(EffectSpace.toWorldDistance(30.0), 6.0))
    }

    @Test("720-step half-degree trigonometric tables")
    func halfDegreeTables() {
        #expect(EffectSpace.halfDegreeSinTable.count == 720)
        #expect(EffectSpace.halfDegreeCosTable.count == 720)

        #expect(approxEqual(EffectSpace.halfDegreeSine(0), 0.0))
        #expect(approxEqual(EffectSpace.halfDegreeCosine(0), 1.0))

        // 90° = 180 half-degrees
        #expect(approxEqual(EffectSpace.halfDegreeSine(180), 1.0))
        #expect(approxEqual(EffectSpace.halfDegreeCosine(180), 0.0))

        // 45° = 90 half-degrees
        let invSqrt2: Float = sqrt(0.5)
        #expect(approxEqual(EffectSpace.halfDegreeSine(90), invSqrt2))
        #expect(approxEqual(EffectSpace.halfDegreeCosine(90), invSqrt2))

        // Wrapping positive and negative indices
        #expect(approxEqual(EffectSpace.halfDegreeSine(900), EffectSpace.halfDegreeSine(180)))
        #expect(approxEqual(EffectSpace.halfDegreeCosine(-180), EffectSpace.halfDegreeCosine(540)))
    }

    @Test("ClientAngles.cpp 722-entry integer-degree table layout and negative lookup")
    func clientAnglesTables() {
        #expect(EffectSpace.radTable.count == 722)
        #expect(EffectSpace.sinTable.count == 722)
        #expect(EffectSpace.cosTable.count == 722)

        // Second half (361...721) is exact negation of first half (0...360)
        for index in [0, 30, 90, 180, 270, 360] {
            #expect(EffectSpace.radTable[index + 361] == -EffectSpace.radTable[index])
            #expect(EffectSpace.sinTable[index + 361] == -EffectSpace.sinTable[index])
            #expect(EffectSpace.cosTable[index + 361] == -EffectSpace.cosTable[index])
        }

        // Standard positive degrees
        #expect(approxEqual(EffectSpace.sine(degrees: 0), 0.0))
        #expect(approxEqual(EffectSpace.cosine(degrees: 0), 1.0))
        #expect(approxEqual(EffectSpace.sine(degrees: 90), 1.0))
        #expect(approxEqual(EffectSpace.cosine(degrees: 90), 0.0))
        #expect(approxEqual(EffectSpace.sine(degrees: 180), 0.0))
        #expect(approxEqual(EffectSpace.cosine(degrees: 180), -1.0))

        // Wrapping > 360 and < -360
        #expect(EffectSpace.sine(degrees: 450) == EffectSpace.sine(degrees: 90))
        #expect(EffectSpace.cosine(degrees: 720) == EffectSpace.cosine(degrees: 0))
        #expect(EffectSpace.radian(degrees: -450) == EffectSpace.radian(degrees: -90))

        // Exact ClientAngles.cpp negative lookup rule: index = 361 + degrees
        #expect(EffectSpace.radian(degrees: -90) == EffectSpace.radTable[271])
        #expect(EffectSpace.sine(degrees: -90) == EffectSpace.sinTable[271])
        #expect(EffectSpace.cosine(degrees: -90) == EffectSpace.cosTable[271])
        #expect(EffectSpace.sine(degrees: -360) == EffectSpace.sinTable[1])
    }

    @Test("Client X -> Y -> Z Euler rotation matches AffineMatrix.cpp row-vector convention")
    func eulerRotationOrder() {
        let halfPi = Float.pi * 0.5

        // Single-axis checks matching MakeXRotation / MakeYRotation / MakeZRotation
        let rx = EffectSpace.rotationX(radians: halfPi)
        #expect(approxEqual(EffectSpace.transformVector(SIMD3<Float>(0, 1, 0), by: rx), SIMD3<Float>(0, 0, 1)))

        let ry = EffectSpace.rotationY(radians: halfPi)
        #expect(approxEqual(EffectSpace.transformVector(SIMD3<Float>(0, 0, 1), by: ry), SIMD3<Float>(1, 0, 0)))

        let rz = EffectSpace.rotationZ(radians: halfPi)
        #expect(approxEqual(EffectSpace.transformVector(SIMD3<Float>(1, 0, 0), by: rz), SIMD3<Float>(0, 1, 0)))

        // Composed X -> Y -> Z
        let xyz = EffectSpace.eulerRotationMatrix(x: halfPi, y: halfPi, z: halfPi)
        #expect(approxEqual(EffectSpace.transformVector(SIMD3<Float>(0, 1, 0), by: xyz), SIMD3<Float>(0, 1, 0)))

        let xy = EffectSpace.eulerRotationMatrix(x: halfPi, y: halfPi, z: 0)
        #expect(approxEqual(EffectSpace.transformVector(SIMD3<Float>(0, 1, 0), by: xy), SIMD3<Float>(1, 0, 0)))

        let xyDeg = EffectSpace.eulerRotationMatrix(degreesX: 90, degreesY: 90, degreesZ: 0)
        #expect(approxEqual(EffectSpace.transformVector(SIMD3<Float>(0, 1, 0), by: xyDeg), SIMD3<Float>(1, 0, 0)))
    }

    @Test("ScaleDistance matches CRenderer::ScaleDistance")
    func scaleDistance() {
        #expect(approxEqual(EffectSpace.scaleDistance(0.5, viewportScaleX: 700.0), 50.0))
        #expect(approxEqual(EffectSpace.scaleDistance(0.0, viewportScaleX: 1280.0), 0.0))
    }

    @Test("EffectSpawnRequest and EffectWorldContext bridge coordinates")
    func contextAndRequestBridge() {
        final class StubWorldContext: EffectWorldContext {
            var cameraWorldPosition: SIMD3<Float> = SIMD3<Float>(10, 5, 10)
            func terrainHeight(atEffectX x: Float, effectZ z: Float) -> Float { 0 }
            func targetState(for targetID: EffectTargetID) -> EffectTargetState? { nil }
            func playSound(named name: String, atWorldPosition position: SIMD3<Float>?, delay: TimeInterval) {}
            func shakeCamera(amplitude: Float, duration: TimeInterval, frequency: Float) {}
            func applyTargetModifier(_ modifier: EffectTargetModifier, to targetID: EffectTargetID) {}
            func spawnChildEffect(_ request: EffectSpawnRequest) {}
        }

        let world = StubWorldContext()
        #expect(approxEqual(world.cameraEffectPosition, SIMD3<Float>(50, -25, -50)))
        #expect(world.isWithinRange(ofEffectPosition: SIMD3<Float>(55, -25, -50), maxDistance: 10))
        #expect(!world.isWithinRange(ofEffectPosition: SIMD3<Float>(100, -25, -50), maxDistance: 10))

        let request = EffectSpawnRequest(
            effectID: .ef_stormgust,
            worldPosition: SIMD3<Float>(2, 1, -3),
            sourceWorldPosition: SIMD3<Float>(0, 0, 0),
            ownerObjectID: 42,
            attachmentKey: .cast
        )
        #expect(request.effectID == .ef_stormgust)
        #expect(approxEqual(request.effectPosition, SIMD3<Float>(10, -5, 15)))
        #expect(approxEqual(request.sourceEffectPosition ?? .zero, .zero))

        let target = EffectTargetState(objectID: 1, worldPosition: SIMD3<Float>(1, 2, 3), headHeight: 2.0)
        #expect(approxEqual(target.effectPosition, SIMD3<Float>(5, -10, -15)))
        #expect(approxEqual(target.effectHeadOffsetY, -10.0))
    }
}
