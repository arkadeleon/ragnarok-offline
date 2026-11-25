//
//  EffectPrimitiveState.swift
//  RagnarokEffects
//
//  Created by Leon Li on 2026/11/24.
//

import simd

/// Historical trail snapshot stored per segment on an `EffectPrimitive`.
public struct EffectPrimitiveRecord: Sendable {
    public var position: SIMD3<Float> = .zero
    public var corners: [SIMD3<Float>] = Array(repeating: .zero, count: 4)
    public var radius: Float = 0
    public var scale: Float = 0
    public var angle: Float = 0
    public var transform: simd_float4x4 = matrix_identity_float4x4
    public var red: Int = 255
    public var green: Int = 255
    public var blue: Int = 255
    public var alpha: Float = 0
    public var color: UInt32 = 0

    public init() {
    }
}

/// Per-slot parametric state (up to 4 slots per `EffectPrimitive`).
public struct EffectPrimitiveSlot: Sendable {
    public var life: Int8 = 0
    public var alphaB: Int16 = 0
    public var alphaT: Int16 = 0
    public var fullDisplayAngle: Int16 = 0
    public var maxHeight: Float = 0
    public var process: Int = 0
    public var rotStart: Int16 = 0
    public var height: [Float] = Array(repeating: 0, count: 21)
    public var flag1: [Int8] = Array(repeating: 0, count: 21)
    public var riseAngle: Int16 = 0
    public var distance: Float = 0
    public var vecBNow: SIMD3<Float> = .zero
    public var vecTNow: SIMD3<Float> = .zero
    public var vecBPre: SIMD3<Float> = .zero
    public var vecTPre: SIMD3<Float> = .zero

    public var targetObjectID: EffectTargetID?

    public init() {
    }
}

/// Complete mutable state of an `EffectPrimitive`, preserving native effect-space defaults.
public struct EffectPrimitiveState: Sendable {
    public enum RenderFlag {
        public static let alpha: UInt32 = 0x1
        public static let additive: UInt32 = 0x2
        public static let customBlend: UInt32 = 0x4
        public static let topmost: UInt32 = 0x8
        public static let alphaRefHigh: UInt32 = 0x10
        public static let secondary: UInt32 = 0x20
        public static let depthSorted: UInt32 = 0x100
        public static let noDepth: UInt32 = 0x200
        public static let preOpaque: UInt32 = 0x800
        public static let postOpaque: UInt32 = 0x1000
    }

    public static let slotCount = 4
    public static let recordCapacity = 50
    public static let defaultChangeSentinel: Float = 0.0001

    public var changePointReached: Bool = false
    public var isChangeProcessed: UInt32 = 0
    public var texturePaths: [String] = []
    public var playWaveName: UInt32 = 0
    public var masterReached: Bool = false
    public var alphaSpeedCycle: UInt32 = 0
    public var alphaCycle: UInt32 = 0
    public var chRadiSpeed: UInt32 = 0
    public var isDisappear: Bool = false

    public var transform: simd_float4x4 = matrix_identity_float4x4
    public var rotTransform: simd_float4x4 = matrix_identity_float4x4

    public var argb: UInt32 = 0xFFFF_FFFF
    public var renderFlag: UInt32 = 1
    public var useRenderFlag: [UInt8] = [0, 0, 0, 0]
    public var type: UInt32 = 0
    public var count: Int = 0
    public var chCnt: UInt32 = 0
    public var colorCycleIndex: Int = 0
    public var pattern: UInt32 = 0
    public var stateCnt: Int = 0
    public var duration: Int = 100
    public var animSpeed: Int = 4
    public var fadeInCnt: Int = -1
    public var fadeOutCnt: Int = -1
    public var numSegment: Int = 1
    public var validAngle: Int = 180
    public var rgbCycleCnt: UInt32 = 0
    public var changePoint: Int = -1
    public var totalTexture: Int = 1
    public var playWaveType: UInt32 = 0
    public var notifyCounts: [UInt8] = Array(repeating: 0, count: 40)
    public var rgbCycleDelay: UInt32 = 0
    public var commonPattern: UInt32 = 0

    public var red: Int = 255
    public var green: Int = 255
    public var blue: Int = 255
    public var redSpeed: Int = 0
    public var greenSpeed: Int = 0
    public var blueSpeed: Int = 0
    public var repeatAnim: Bool = true

    public var chPoint: [Float] = []
    public var chVal1: [Float] = []
    public var chVal2: [Float] = []
    public var chVal3: [Float] = []

    public var arcAngle: Float = 36.0
    public var minRadius: UInt32 = 0
    public var rotAxis: SIMD3<Float> = .zero

    public var changeSpeed: Float = EffectPrimitiveState.defaultChangeSentinel
    public var changeAccel: Float = EffectPrimitiveState.defaultChangeSentinel
    public var changeSpeed3d: SIMD3<Float> = .zero
    public var changeAccel3d: SIMD3<Float> = .zero
    public var speed: Float = 0
    public var accel: Float = 0
    public var changeWidthAccel: Float = EffectPrimitiveState.defaultChangeSentinel
    public var changeWidthSpeed: Float = EffectPrimitiveState.defaultChangeSentinel
    public var changeHeightSpeed: Float = EffectPrimitiveState.defaultChangeSentinel
    public var changeHeightAccel: Float = EffectPrimitiveState.defaultChangeSentinel

    public var maxAlpha: Float = 254.0
    public var minAlpha: Float = 0
    public var u1: Float = 0
    public var u2: Float = 1.0
    public var v1: Float = 0
    public var v2: Float = 1.0

    public var gravSpeed: Float = 0
    public var gravAccel: Float = 0
    public var innerSize: Float = 0
    public var outerSize: Float = 0
    public var innerSpeed: Float = 0
    public var outerSpeed: Float = 0
    public var innerAccel: Float = 0
    public var outerAccel: Float = 0

    public var longitude: Float = 0
    public var latitude: Float = 0
    public var roll: Float = 0
    public var size: Float = 1.0
    public var sizeSpeed: Float = 0
    public var sizeAccel: Float = 0
    public var alpha: Float = 254.0
    public var alphaSpeed: Float = 0
    public var alphaDelta: Float = 1.0
    public var longSpeed: Float = 0
    public var latiSpeed: Float = 0
    public var rollSpeed: Float = 0
    public var longAccel: Float = 0
    public var latiAccel: Float = 0
    public var rollAccel: Float = 0
    public var radius: Float = 0
    public var radiusSpeed: Float = 0
    public var radiusAccel: Float = 0
    public var widthSize: Float = 0
    public var widthSpeed: Float = 0
    public var widthAccel: Float = 0
    public var heightSize: Float = 0
    public var heightSpeed: Float = 0
    public var heightAccel: Float = 0
    public var maxHeightSize: Float = 100.0

    public var speed3d: SIMD3<Float> = .zero
    public var orgPos: SIMD3<Float> = .zero
    public var deltaPos: SIMD3<Float> = .zero
    public var deltaPos2: SIMD3<Float> = .zero
    public var deltaPos3: SIMD3<Float> = .zero
    public var deltaPosAccel: SIMD3<Float> = .zero
    public var segPos: [SIMD3<Float>] = Array(repeating: .zero, count: 4)

    public var slots: [EffectPrimitiveSlot] = Array(repeating: EffectPrimitiveSlot(), count: EffectPrimitiveState.slotCount)
    public var records: [EffectPrimitiveRecord] = Array(repeating: EffectPrimitiveRecord(), count: EffectPrimitiveState.recordCapacity)
    public var spriteLift: Int64 = 0

    public var cooldownSkillID: Int?

    public init() {
    }
}
