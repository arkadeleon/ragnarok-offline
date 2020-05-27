//
//  Matrix3.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/27.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import simd
import GLKit

typealias Matrix3 = matrix_float3x3

extension Matrix3 {

    init(_ glkMatrix3: GLKMatrix3) {
        self.init([
            [glkMatrix3.m00, glkMatrix3.m01, glkMatrix3.m02],
            [glkMatrix3.m10, glkMatrix3.m11, glkMatrix3.m12],
            [glkMatrix3.m20, glkMatrix3.m21, glkMatrix3.m22]
        ])
    }
}

extension Matrix3 {

    static var identity: Matrix3 {
        let glkMatrix3 = GLKMatrix3Identity
        return Matrix3(glkMatrix3)
    }

    init(scaleX sx: Float, y sy: Float, z sz: Float) {
        let glkMatrix3 = GLKMatrix3MakeScale(sx, sy, sz)
        self.init(glkMatrix3)
    }

    init(rotationAngle angle: Float, x: Float, y: Float, z: Float) {
        let glkMatrix3 = GLKMatrix3MakeRotation(angle, x, y, z)
        self.init(glkMatrix3)
    }

    init(xRotationAngle angle: Float) {
        let glkMatrix3 = GLKMatrix3MakeXRotation(angle)
        self.init(glkMatrix3)
    }

    init(yRotationAngle angle: Float) {
        let glkMatrix3 = GLKMatrix3MakeYRotation(angle)
        self.init(glkMatrix3)
    }

    init(zRotationAngle angle: Float) {
        let glkMatrix3 = GLKMatrix3MakeZRotation(angle)
        self.init(glkMatrix3)
    }
}
