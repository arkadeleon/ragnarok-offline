//
//  Particle.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/27.
//

import Foundation
import simd

/// Star/spark auxiliary motion state attached to a `Particle`.
public struct StarParticleState: Sendable, Equatable {
    public var angle: Float = 0
    public var angleSpeed: Float = 0
    public var radius: Float = 0
    public var radiusSpeed: Float = 0
    public var speed: Float = 0
    public var targetPosition: SIMD3<Float> = .zero

    public init() {}
}

/// Textured 3D quad particle submitted to `EffectPrimitiveBatchCollector`.
@MainActor
public final class Particle {
    public var active: Bool = false
    public var effectID: EffectID = .ef_none
    public var groupIndex: Int = 0
    public var columnIndex: Int = 0
    public var rowIndex: Int = 0

    public var position: SIMD3<Float> = .zero
    public var velocity: SIMD3<Float> = .zero
    public var acceleration: SIMD3<Float> = .zero
    public var offset: SIMD3<Float> = .zero

    public var scale: Float = 1.0
    public var width: Float = 1.0
    public var height: Float = 1.0
    public var angleX: Float = 0
    public var angleY: Float = 0
    public var angleZ: Float = 0
    public var animationParameter: Float = 0

    public var life: Float = 0
    public var elapsedFrames: Int = 0

    public var red: UInt8 = 255
    public var green: UInt8 = 255
    public var blue: UInt8 = 255
    public var alpha: UInt8 = 255

    public var sourceBlend: Int32 = EffectBlendFactor.sourceAlpha.rawValue
    public var destinationBlend: Int32 = EffectBlendFactor.one.rawValue
    public var texturePath: String = ""

    /// Local quad vertices matching the client's unit quad `(-1, 1, 1)...(1, -1, 1)`.
    public var localVertices: (SIMD3<Float>, SIMD3<Float>, SIMD3<Float>, SIMD3<Float>) = (
        SIMD3<Float>(-1, 1, 1),
        SIMD3<Float>(1, 1, 1),
        SIMD3<Float>(-1, -1, 1),
        SIMD3<Float>(1, -1, 1)
    )

    /// Column-vector affine transform applied to `localVertices`.
    public var transform: simd_float4x4 = matrix_identity_float4x4

    public var starState = StarParticleState()

    public init(position: SIMD3<Float> = .zero) {
        self.position = position
    }

    public func reset(position: SIMD3<Float> = .zero) {
        self.active = false
        self.position = position
        self.velocity = .zero
        self.acceleration = .zero
        self.offset = .zero
        self.scale = 1.0
        self.width = 1.0
        self.height = 1.0
        self.angleX = 0
        self.angleY = 0
        self.angleZ = 0
        self.animationParameter = 0
        self.life = 0
        self.elapsedFrames = 0
        self.red = 255
        self.green = 255
        self.blue = 255
        self.alpha = 255
        self.sourceBlend = EffectBlendFactor.sourceAlpha.rawValue
        self.destinationBlend = EffectBlendFactor.one.rawValue
        self.transform = matrix_identity_float4x4
        self.localVertices = (
            SIMD3<Float>(-1, 1, 1),
            SIMD3<Float>(1, 1, 1),
            SIMD3<Float>(-1, -1, 1),
            SIMD3<Float>(1, -1, 1)
        )
    }

    public func setColor(_ red: UInt8, _ green: UInt8, _ blue: UInt8) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    public func setTexture(_ path: String) {
        self.texturePath = path
    }

    /// Submits the particle quad to `collector`.
    /// - Parameter usesTransformDirectly: When `false`, appends camera-yaw rotation and `position` translation
    ///   around `transform` (billboard placement). When `true`, uses `transform` directly in effect space.
    public func render(
        into collector: inout EffectPrimitiveBatchCollector,
        world: any EffectWorldContext,
        assets: EffectAssetStore?,
        usesTransformDirectly: Bool = false,
        uvTop: Float = 0.0,
        uvBottom: Float = 1.0,
        uvLeft: Float = 0.0,
        uvRight: Float = 1.0,
        depthTest: Bool = true
    ) {
        let placedTransform: simd_float4x4
        if usesTransformDirectly {
            placedTransform = transform
        } else {
            let cameraYawRadians = world.cameraYawDegrees / 180.0 * EffectSpace.clientPi
            let yawMatrix = EffectSpace.rotationY(radians: cameraYawRadians)
            let translationMatrix = ParticleMath.makeTranslationMatrix(position)
            placedTransform = translationMatrix * yawMatrix * transform
        }

        let pTL = EffectSpace.transformPoint(localVertices.0, by: placedTransform)
        let pTR = EffectSpace.transformPoint(localVertices.1, by: placedTransform)
        let pBL = EffectSpace.transformPoint(localVertices.2, by: placedTransform)
        let pBR = EffectSpace.transformPoint(localVertices.3, by: placedTransform)

        let color = SIMD4<Float>(
            Float(red) / 255.0,
            Float(green) / 255.0,
            Float(blue) / 255.0,
            Float(alpha) / 255.0
        )

        let texture = texturePath.isEmpty ? nil : assets?.texture(atPath: texturePath)
        let renderState = EffectPrimitiveRenderState(
            srcBlend: EffectBlendFactor(d3dBlend: sourceBlend),
            dstBlend: EffectBlendFactor(d3dBlend: destinationBlend),
            depthTest: depthTest,
            depthWrite: false
        )

        collector.appendEffectQuad(
            p0: pTL,
            p1: pTR,
            p2: pBR,
            p3: pBL,
            uv0: SIMD2<Float>(uvLeft, uvTop),
            uv1: SIMD2<Float>(uvRight, uvTop),
            uv2: SIMD2<Float>(uvRight, uvBottom),
            uv3: SIMD2<Float>(uvLeft, uvBottom),
            color0: color,
            color1: color,
            color2: color,
            color3: color,
            texture: texture,
            renderState: renderState,
            effectCenter: position
        )
    }
}
