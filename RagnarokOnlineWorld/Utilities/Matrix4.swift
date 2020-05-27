//
//  Matrix4.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/27.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import simd
import GLKit

typealias Matrix4 = matrix_float4x4

extension Matrix4 {

    init(_ glkMatrix4: GLKMatrix4) {
        self.init([
            [glkMatrix4.m00, glkMatrix4.m01, glkMatrix4.m02, glkMatrix4.m03],
            [glkMatrix4.m10, glkMatrix4.m11, glkMatrix4.m12, glkMatrix4.m13],
            [glkMatrix4.m20, glkMatrix4.m21, glkMatrix4.m22, glkMatrix4.m23],
            [glkMatrix4.m30, glkMatrix4.m31, glkMatrix4.m32, glkMatrix4.m33]
        ])
    }
}

extension Matrix4 {

    static var identity: Matrix4 {
        let glkMatrix4 = GLKMatrix4Identity
        return Matrix4(glkMatrix4)
    }

    init(translationX tx: Float, y ty: Float, z tz: Float) {
        let glkMatrix4 = GLKMatrix4MakeTranslation(tx, ty, tz)
        self.init(glkMatrix4)
    }

    init(scaleX sx: Float, y sy: Float, z sz: Float) {
        let glkMatrix4 = GLKMatrix4MakeScale(sx, sy, sz)
        self.init(glkMatrix4)
    }

    init(rotationAngle angle: Float, x: Float, y: Float, z: Float) {
        let glkMatrix4 = GLKMatrix4MakeRotation(angle, x, y, z)
        self.init(glkMatrix4)
    }

    init(xRotationAngle angle: Float) {
        let glkMatrix4 = GLKMatrix4MakeXRotation(angle)
        self.init(glkMatrix4)
    }

    init(yRotationAngle angle: Float) {
        let glkMatrix4 = GLKMatrix4MakeYRotation(angle)
        self.init(glkMatrix4)
    }

    init(zRotationAngle angle: Float) {
        let glkMatrix4 = GLKMatrix4MakeZRotation(angle)
        self.init(glkMatrix4)
    }

    init(perspectiveFovyAngle fovyAngle: Float, aspect: Float, nearZ: Float, farZ: Float) {
        let glkMatrix4 = GLKMatrix4MakePerspective(fovyAngle, aspect, nearZ, farZ)
        self.init(glkMatrix4)
    }
}
