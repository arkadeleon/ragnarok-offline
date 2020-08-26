//
//  SGLMath+SIMD.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/6/29.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import SGLMath

extension Vector3 where T == Float {

    var simd: simd_float3 {
        unsafeBitCast(Vector4(self, 0), to: simd_float3.self)
    }
}

extension Vector4 where T == Float {

    var simd: simd_float4 {
        unsafeBitCast(self, to: simd_float4.self)
    }
}

extension Matrix3x3 where T == Float {

    var simd: simd_float3x3 {
        unsafeBitCast(Matrix3x4(self), to: simd_float3x3.self)
    }
}

extension Matrix4x4 where T == Float {

    var simd: simd_float4x4 {
        unsafeBitCast(self, to: simd_float4x4.self)
    }
}
