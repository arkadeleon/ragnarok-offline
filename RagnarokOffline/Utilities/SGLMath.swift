//
//  SGLMath.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/9.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import simd

public func radians<T: FloatingPoint>(_ degrees: T) -> T {
    return degrees * .pi / 180
}

public func degrees<T: FloatingPoint>(_ radians: T) -> T {
    return radians * 180 / .pi
}

public func matrix_translate(_ m: simd_float4x4, _ v: simd_float3) -> simd_float4x4 {
    var m3 = m[0] * v[0]
    m3 += m[1] * v[1]
    m3 += m[2] * v[2]
    m3 += m[3]
    return simd_float4x4(m[0], m[1], m[2], m3)
}

public func matrix_rotate(_ m: simd_float4x4, _ angle: Float, _ v: simd_float3) -> simd_float4x4 {
    let a = angle
    let c = cos(a)
    let s = sin(a)
    let axis = simd_normalize(v)
    let temp = (1 - c) * axis
    var r00 = c
        r00 += temp[0] * axis[0]
    var r01 = temp[0] * axis[1]
        r01 += s * axis[2]
    var r02 = temp[0] * axis[2]
        r02 -= s * axis[1]
    var r10 = temp[1] * axis[0]
        r10 -= s * axis[2]
    var r11 = c
        r11 += temp[1] * axis[1]
    var r12 = temp[1] * axis[2]
        r12 += s * axis[0]
    var r20 = temp[2] * axis[0]
        r20 += s * axis[1]
    var r21 = temp[2] * axis[1]
        r21 -= s * axis[0]
    var r22 = c
        r22 += temp[2] * axis[2]

    var result = simd_float4x4(
        m[0] * r00,
        m[0] * r10,
        m[0] * r20,
        m[3]
    )
    result[0] += m[1] * r01
    result[0] += m[2] * r02
    result[1] += m[1] * r11
    result[1] += m[2] * r12
    result[2] += m[1] * r21
    result[2] += m[2] * r22
    return result
}

public func matrix_scale(_ m: simd_float4x4, _ v: simd_float3) -> simd_float4x4 {
    return simd_float4x4(
        m[0] * v[0],
        m[1] * v[1],
        m[2] * v[2],
        m[3]
    )
}

public func perspective(_ fovy: Float, _ aspect: Float, _ zNear: Float, _ zFar: Float) -> simd_float4x4 {
    assert(aspect > 0)

    let tanHalfFovy = tan(fovy / 2)

    let r00 = 1 / (aspect * tanHalfFovy)
    let r11 = 1 / (tanHalfFovy)

    let r22 = -(zFar + zNear) / (zFar - zNear)
    var r32 = -(2 * zFar * zNear)
    r32 /= (zFar - zNear)

    return simd_float4x4(
        [r00, 0, 0, 0],
        [0, r11, 0, 0],
        [0, 0, r22, -1],
        [0, 0, r32, 0]
    )
}

public func lookAt(_ eye: simd_float3, _ center: simd_float3, _ up: simd_float3) -> simd_float4x4 {
    let f = simd_normalize(center - eye)
    let s = simd_normalize(simd_cross(up, f))
    let u = simd_cross(f, s)

    let r30 = -simd_dot(s, eye)
    let r31 = -simd_dot(u, eye)
    let r32 = -simd_dot(f, eye)

    return simd_float4x4(
        [s.x, u.x, f.x, 0],
        [s.y, u.y, f.y, 0],
        [s.z, u.z, f.z, 0],
        [r30, r31, r32, 1]
    )
}

extension simd_float3x3 {
    init(_ m: simd_float4x4) {
        self.init(
            [m[0, 0], m[0, 1], m[0, 2]],
            [m[1, 0], m[1, 1], m[1, 2]],
            [m[2, 0], m[2, 1], m[2, 2]]
        )
    }
}

extension simd_float4x4 {
    init(_ m: simd_float3x3) {
        self.init(
            [m[0, 0], m[0, 1], m[0, 2], 0.0],
            [m[1, 0], m[1, 1], m[1, 2], 0.0],
            [m[2, 0], m[2, 1], m[2, 2], 0.0],
            [0.0, 0.0, 0.0, 1.0]
        )
    }
}

extension simd_float4x4 {
    init(translation: simd_float3) {
        self = simd_float4x4(
            [            1,             0,             0, 0],
            [            0,             1,             0, 0],
            [            0,             0,             1, 0],
            [translation.x, translation.y, translation.z, 1]
        )
    }

    init(rotationX angle: Float) {
        self = simd_float4x4(
            [1,           0,          0, 0],
            [0,  cos(angle), sin(angle), 0],
            [0, -sin(angle), cos(angle), 0],
            [0,           0,          0, 1]
        )
    }

    init(rotationY angle: Float) {
        self = simd_float4x4(
            [cos(angle), 0, -sin(angle), 0],
            [         0, 1,           0, 0],
            [sin(angle), 0,  cos(angle), 0],
            [         0, 0,           0, 1]
        )
    }

    init(rotationZ angle: Float) {
        self = simd_float4x4(
            [ cos(angle), sin(angle), 0, 0],
            [-sin(angle), cos(angle), 0, 0],
            [          0,          0, 1, 0],
            [          0,          0, 0, 1]
        )
    }

    init(rotationXYZ angle: simd_float3) {
        let rotationX = simd_float4x4(rotationX: angle.x)
        let rotationY = simd_float4x4(rotationY: angle.y)
        let rotationZ = simd_float4x4(rotationZ: angle.z)
        self = rotationX * rotationY * rotationZ
    }
}
