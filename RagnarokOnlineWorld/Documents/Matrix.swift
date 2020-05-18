//
//  Matrix.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/15.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import simd

typealias Vector2 = SIMD2
typealias Vector3 = SIMD3
typealias Vector4 = SIMD4

typealias Matrix3 = simd_float3x3
typealias Matrix4 = simd_float4x4

extension Matrix3 {

    static var identity: Matrix3 {
        return matrix_identity_float3x3
    }

    init(translationX tx: Float, y ty: Float) {
        self.init(rows: [
            [1,  0,  0],
            [0,  1,  0],
            [tx, ty, 1]
        ])
    }

    init(scaleX sx: Float, y sy: Float) {
        self.init(rows: [
            [sx, 0,  0],
            [0,  sy, 0],
            [0,  0,  1]
        ])
    }

    init(rotationAngle angle: Float) {
        self.init(rows: [
            [ cos(angle), sin(angle), 0],
            [-sin(angle), cos(angle), 0],
            [ 0,          0,          1]
        ])
    }

    func translatedBy(x tx: Float, y ty: Float) -> Matrix3 {
        return self * Matrix3(translationX: tx, y: ty)
    }

    func scaledBy(x sx: Float, y sy: Float) -> Matrix3 {
        return self * Matrix3(scaleX: sx, y: sy)
    }

    func rotated(by angle: Float) -> Matrix3 {
        return self * Matrix3(rotationAngle: angle)
    }
}

/// Calculate a normal from the three givens vectors
func calcNormal(_ a: Vector3<Float>, _ b: Vector3<Float>, _ c: Vector3<Float>) -> Vector3<Float> {
    let v1 = c - b
    let v2 = a - b
    let v3 = cross(v1, v2)
    return normalize(v3)
}

/// Create a normal with the four givens vector
func calcNormal(_ a: Vector3<Float>, _ b: Vector3<Float>, _ c: Vector3<Float>, _ d: Vector3<Float>) -> Vector3<Float> {
    var v1 = c - b
    var v2 = a - b
    var v3 = cross(v1, v2)
    var v = normalize(v3)

    v1 = a - d
    v2 = c - d
    v3 = cross(v1, v2)
    v += normalize(v3)

    return normalize(v)
}

/// Translates a matrix by the given Z property
func translateZ(_ mat: Matrix4, _ z: Float) -> Matrix4 {
    var dest = mat
    dest[0, 3] += dest[0, 2] * z
    dest[1, 3] += dest[1, 2] * z
    dest[2, 3] += dest[2, 2] * z
    dest[3, 3] += dest[3, 2] * z
    return dest
}

/// Do a quaternon rotation
func rotateQuat(_ mat: Matrix4, _ w: Vector4<Float>) -> Matrix4 {
    let norm = normalize(w)
    let a = norm[0]
    let b = norm[1]
    let c = norm[2]
    let d = norm[3]

    let m = Matrix4(rows: [
        [1.0 - 2.0 * ( b * b + c * c ),     2.0 * (a * b + c * d),            2.0 * (a * c - b * d),           0.0],
        [2.0 * ( a * b - c * d ),           1.0 - 2.0 * ( a * a + c * c ),    2.0 * (c * b + a * d ),          0.0],
        [2.0 * ( a * c + b * d ),           2.0 * ( b * c - a * d ),          1.0 - 2.0 * ( a * a + b * b ),   0.0],
        [0.0,                               0.0,                              0.0,                             1.0]
    ])
    return matrix_multiply(mat, m)
}

/// Extract rotation matrix
func extractRotation(_ mat: Matrix4) -> Matrix4 {
    let x: Vector3<Float> = [mat[0, 0], mat[1, 0], mat[2, 0]]
    let norm_x = normalize(x)

    let y: Vector3<Float> = [mat[0, 1], mat[1, 1], mat[2, 1]]
    let norm_y = normalize(y)

    let z: Vector3<Float> = [mat[0, 2], mat[1, 2], mat[2, 2]]
    let norm_z = normalize(z)

    var dest: Matrix4 = matrix_identity_float4x4
    dest[0, 0] = norm_x[0]
    dest[1, 0] = norm_x[1]
    dest[2, 0] = norm_x[2]
    dest[0, 1] = norm_y[0]
    dest[1, 1] = norm_y[1]
    dest[2, 1] = norm_y[2]
    dest[0, 2] = norm_z[0]
    dest[1, 2] = norm_z[1]
    dest[2, 2] = norm_z[2]
    return dest
}

/// Copies the elements of a mat3 into the upper 3x3 elements of a mat4
func mat3tomat4(_ mat: Matrix3) -> Matrix4 {
    var dest: Matrix4 = matrix_identity_float4x4
    dest[0, 0] = mat[0, 0]
    dest[1, 0] = mat[1, 0]
    dest[2, 0] = mat[2, 0]
    dest[0, 1] = mat[0, 1]
    dest[1, 1] = mat[1, 1]
    dest[2, 1] = mat[2, 1]
    dest[0, 2] = mat[0, 2]
    dest[1, 2] = mat[1, 2]
    dest[2, 2] = mat[2, 2]
    return dest
}

/// Calculates the inverse of the upper 3x3 elements of a mat4 and copies the result into a mat3
/// The resulting matrix is useful for calculating transformed normals
func mat4toInverseMat3(_ mat: Matrix4) -> Matrix3 {
    let a00 = mat[0, 0]
    let a01 = mat[1, 0]
    let a02 = mat[2, 0]
    let a10 = mat[0, 1]
    let a11 = mat[1, 1]
    let a12 = mat[2, 1]
    let a20 = mat[0, 2]
    let a21 = mat[1, 2]
    let a22 = mat[2, 2]

    let b01 = a22 * a11 - a12 * a21
    let b11 = -a22 * a10 + a12 * a20
    let b21 = a21 * a10 - a11 * a20

    let d = a00 * b01 + a01 * b11 + a02 * b21
    if d == 0 {
        return .identity
    }

    let id = 1 / d

    var dest: Matrix3 = .identity
    dest[0, 0] = b01 * id
    dest[1, 0] = (-a22 * a01 + a02 * a21) * id
    dest[2, 0] = (a12 * a01 - a02 * a11) * id
    dest[0, 1] = b11 * id
    dest[1, 1] = (a22 * a00 - a02 * a20) * id
    dest[2, 1] = (-a12 * a00 + a02 * a10) * id
    dest[0, 2] = b21 * id
    dest[1, 2] = (-a21 * a00 + a01 * a20) * id
    dest[2, 2] = (a11 * a00 - a01 * a10) * id
    return dest
}
