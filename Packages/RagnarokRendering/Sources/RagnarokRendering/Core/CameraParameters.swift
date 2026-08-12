//
//  CameraParameters.swift
//  RagnarokRendering
//
//  Created by Leon Li on 2026/8/10.
//

import simd

public struct CameraParameters {
    public var modelMatrix: simd_float4x4
    public var viewMatrix: simd_float4x4
    public var projectionMatrix: simd_float4x4
    public var cameraPosition: SIMD3<Float>
    public var cameraAzimuth: Float
    public var cameraElevation: Float

    public var normalMatrix: simd_float3x3 {
        simd_float3x3(modelMatrix).inverse.transpose
    }

    public init(
        modelMatrix: simd_float4x4 = matrix_identity_float4x4,
        viewMatrix: simd_float4x4 = matrix_identity_float4x4,
        projectionMatrix: simd_float4x4 = matrix_identity_float4x4,
        cameraPosition: SIMD3<Float> = .zero,
        cameraAzimuth: Float = 0,
        cameraElevation: Float = 0
    ) {
        self.modelMatrix = modelMatrix
        self.viewMatrix = viewMatrix
        self.projectionMatrix = projectionMatrix
        self.cameraPosition = cameraPosition
        self.cameraAzimuth = cameraAzimuth
        self.cameraElevation = cameraElevation
    }

    public init(modelMatrix: simd_float4x4 = matrix_identity_float4x4, camera: RenderCamera) {
        self.init(
            modelMatrix: modelMatrix,
            viewMatrix: camera.viewMatrix,
            projectionMatrix: camera.projectionMatrix,
            cameraPosition: camera.position,
            cameraAzimuth: camera.azimuth,
            cameraElevation: camera.elevation
        )
    }
}
