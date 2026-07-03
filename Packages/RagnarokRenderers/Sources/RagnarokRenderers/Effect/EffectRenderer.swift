//
//  EffectRenderer.swift
//  RagnarokRenderers
//
//  Created by Leon Li on 2026/6/30.
//

import Metal
import simd

public final class EffectRenderer {
    public let device: any MTLDevice

    private let effect3DRenderer: Effect3DRenderer
    private let cylinderEffectRenderer: CylinderEffectRenderer
    private let sprEffectRenderer: SPREffectRenderer
    private let strEffectRenderer: STREffectRenderer

    public init(device: any MTLDevice) throws {
        self.device = device

        effect3DRenderer = try Effect3DRenderer(device: device)
        cylinderEffectRenderer = try CylinderEffectRenderer(device: device)
        sprEffectRenderer = try SPREffectRenderer(device: device)
        strEffectRenderer = try STREffectRenderer(device: device)
    }

    public func render(
        resource: EffectRenderResource,
        atTime time: TimeInterval,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        modelMatrix: simd_float4x4,
        viewMatrix: simd_float4x4,
        projectionMatrix: simd_float4x4,
        cameraAzimuth: Float
    ) {
        for component in resource.components {
            render(
                component: component,
                atTime: time,
                renderCommandEncoder: renderCommandEncoder,
                modelMatrix: modelMatrix,
                viewMatrix: viewMatrix,
                projectionMatrix: projectionMatrix,
                cameraAzimuth: cameraAzimuth
            )
        }
    }

    public func render(
        component: EffectRenderResourceComponent,
        atTime time: TimeInterval,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        modelMatrix: simd_float4x4,
        viewMatrix: simd_float4x4,
        projectionMatrix: simd_float4x4,
        cameraAzimuth: Float
    ) {
        switch component {
        case .`3D`(let resource):
            effect3DRenderer.render(
                resource: resource,
                atTime: time,
                renderCommandEncoder: renderCommandEncoder,
                viewMatrix: viewMatrix,
                projectionMatrix: projectionMatrix,
                cameraAzimuth: cameraAzimuth
            )
        case .cylinder(let resource):
            cylinderEffectRenderer.render(
                resource: resource,
                atTime: time,
                renderCommandEncoder: renderCommandEncoder,
                viewMatrix: viewMatrix,
                projectionMatrix: projectionMatrix,
                cameraAzimuth: cameraAzimuth
            )
        case .spr(let resource):
            sprEffectRenderer.render(
                resource: resource,
                atTime: time,
                renderCommandEncoder: renderCommandEncoder,
                viewMatrix: viewMatrix,
                projectionMatrix: projectionMatrix
            )
        case .str(let resource):
            strEffectRenderer.render(
                resource: resource,
                atTime: time,
                renderCommandEncoder: renderCommandEncoder,
                modelMatrix: modelMatrix,
                viewMatrix: viewMatrix,
                projectionMatrix: projectionMatrix
            )
        }
    }
}
