//
//  SGLMath+Calculate.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/6/16.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

func calcNormal(_ a: simd_float3, _ b: simd_float3, _ c: simd_float3) -> simd_float3 {
    let v1 = c - b
    let v2 = a - b
    let v3 = simd_cross(v1, v2)
    return simd_normalize(v3)
}

func calcNormal(_ a: simd_float3, _ b: simd_float3, _ c: simd_float3, _ d: simd_float3) -> simd_float3 {
    var v1 = c - b
    var v2 = a - b
    var v3 = simd_cross(v1, v2)
    var v = simd_normalize(v3)

    v1 = a - d
    v2 = c - d
    v3 = simd_cross(v1, v2)
    v += simd_normalize(v3)

    return simd_normalize(v)
}

func translateZ(_ mat: simd_float4x4, _ z: Float) -> simd_float4x4 {
    var dest = mat
    dest[3] += dest[2] * z
    return dest
}

func rotateQuat(_ mat: simd_float4x4, w: simd_float4) -> simd_float4x4 {
    let norm = simd_normalize(w)
    let a = norm[0]
    let b = norm[1]
    let c = norm[2]
    let d = norm[3]


    let m = simd_float4x4(
        [1.0 - 2.0 * (b * b + c * c), 2.0 * (a * b + c * d),       2.0 * (a * c - b * d),       0.0],
        [2.0 * (a * b - c * d),       1.0 - 2.0 * (a * a + c * c), 2.0 * (c * b + a * d),       0.0],
        [2.0 * (a * c + b * d),       2.0 * (b * c - a * d),       1.0 - 2.0 * (a * a + b * b), 0.0],
        [0.0,                         0.0,                         0.0,                         1.0]
    )
    return mat * m
}

func extractRotation(_ mat: simd_float4x4) -> simd_float4x4 {
    let x: simd_float3 = [mat[0, 0], mat[0, 1], mat[0, 2]]
    let norm_x = simd_normalize(x)

    let y: simd_float3 = [mat[1, 0], mat[1, 1], mat[1, 2]]
    let norm_y = simd_normalize(y)

    let z: simd_float3 = [mat[2, 0], mat[2, 1], mat[2, 2]]
    let norm_z = simd_normalize(z)

    return simd_float4x4(
        [norm_x[0], norm_x[1], norm_x[2], 0.0],
        [norm_y[0], norm_y[1], norm_y[2], 0.0],
        [norm_z[0], norm_z[1], norm_z[2], 0.0],
        [0.0, 0.0, 0.0, 1.0]
    )
}
