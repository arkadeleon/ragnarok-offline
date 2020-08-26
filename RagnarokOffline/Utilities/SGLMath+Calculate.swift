//
//  SGLMath+Calculate.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/6/16.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import SGLMath

extension SGLMath {

    static func calcNormal(_ a: Vector3<Float>, _ b: Vector3<Float>, _ c: Vector3<Float>) -> Vector3<Float> {
        let v1 = c - b
        let v2 = a - b
        let v3 = cross(v1, v2)
        return normalize(v3)
    }

    static func calcNormal(_ a: Vector3<Float>, _ b: Vector3<Float>, _ c: Vector3<Float>, _ d: Vector3<Float>) -> Vector3<Float> {
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

    static func translateZ(_ mat: Matrix4x4<Float>, _ z: Float) -> Matrix4x4<Float> {
        var dest = mat
        dest[3] += dest[2] * z
        return dest
    }

    static func rotateQuat(_ mat: Matrix4x4<Float>, w: Vector4<Float>) -> Matrix4x4<Float> {
        let norm = normalize(w)
        let a = norm[0]
        let b = norm[1]
        let c = norm[2]
        let d = norm[3]
        

        let m = Matrix4x4(
            1.0 - 2.0 * (b * b + c * c), 2.0 * (a * b + c * d),       2.0 * (a * c - b * d),       0.0,
            2.0 * (a * b - c * d),       1.0 - 2.0 * (a * a + c * c), 2.0 * (c * b + a * d),       0.0,
            2.0 * (a * c + b * d),       2.0 * (b * c - a * d),       1.0 - 2.0 * (a * a + b * b), 0.0,
            0.0,                         0.0,                         0.0,                         1.0
        )
        return mat * m
    }

    static func extractRotation(_ mat: Matrix4x4<Float>) -> Matrix4x4<Float> {
        let x = Vector3(mat[0, 0], mat[0, 1], mat[0, 2])
        let norm_x = normalize(x)

        let y = Vector3(mat[1, 0], mat[1, 1], mat[1, 2])
        let norm_y = normalize(y)

        let z = Vector3(mat[2, 0], mat[2, 1], mat[2, 2])
        let norm_z = normalize(z)

        var dest = Matrix4x4<Float>()
        dest[0] = Vector4(norm_x, 0.0)
        dest[1] = Vector4(norm_y, 0.0)
        dest[2] = Vector4(norm_z, 0.0);
        return dest
    }
}
