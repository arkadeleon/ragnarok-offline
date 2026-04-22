//
//  SkyboxRenderResource.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/22.
//

import CoreGraphics
import Metal
import RagnarokShaders
import simd

final class SkyboxRenderResource {
    private let device: any MTLDevice
    private let configuration: SkyboxConfiguration

    let uniformsBuffer: (any MTLBuffer)?

    init(device: any MTLDevice, configuration: SkyboxConfiguration) {
        self.device = device
        self.configuration = configuration

        uniformsBuffer = device.makeBuffer(
            length: MemoryLayout<SkyboxUniforms>.size,
            options: .storageModeShared
        )
    }

    func writeUniforms(
        projectionMatrix: simd_float4x4,
        viewMatrix: simd_float4x4,
        cameraPosition: SIMD3<Float>
    ) -> Bool {
        guard let uniformsBuffer else {
            return false
        }

        let inverseViewProjectionMatrix = (projectionMatrix * viewMatrix).inverse
        var uniforms = SkyboxUniforms(
            topColor: simd4(from: configuration.topColor),
            horizonColor: simd4(from: configuration.horizonColor),
            bottomColor: simd4(from: configuration.bottomColor),
            sphereCenterAndRadius: SIMD4<Float>(
                configuration.center.x,
                configuration.center.y,
                configuration.center.z,
                configuration.radius
            ),
            cameraPosition: SIMD4<Float>(
                cameraPosition.x,
                cameraPosition.y,
                cameraPosition.z,
                1
            ),
            inverseViewProjectionMatrix: inverseViewProjectionMatrix
        )
        memcpy(uniformsBuffer.contents(), &uniforms, MemoryLayout<SkyboxUniforms>.size)
        return true
    }

    private func simd4(from color: CGColor) -> SIMD4<Float> {
        guard let components = color.components, components.count >= 3 else {
            return .zero
        }
        return SIMD4<Float>(Float(components[0]), Float(components[1]), Float(components[2]), 1)
    }
}
