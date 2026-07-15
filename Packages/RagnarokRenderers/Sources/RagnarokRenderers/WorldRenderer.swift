//
//  WorldRenderer.swift
//  RagnarokRenderers
//
//  Created by Leon Li on 2026/7/14.
//

import Foundation
import Metal
import simd

public final class WorldRenderer {
    public let device: any MTLDevice

    private let groundRenderer: GroundRenderer
    private let waterRenderer: WaterRenderer
    private let modelRenderer: RSMModelRenderer
    private let effectRenderer: EffectRenderer

    public init(device: any MTLDevice) throws {
        self.device = device

        groundRenderer = try GroundRenderer(device: device)
        waterRenderer = try WaterRenderer(device: device)
        modelRenderer = try RSMModelRenderer(device: device)
        effectRenderer = try EffectRenderer(device: device)
    }

    public func render(
        resource: WorldRenderResource,
        atTime time: TimeInterval,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        modelMatrix: simd_float4x4,
        viewMatrix: simd_float4x4,
        projectionMatrix: simd_float4x4,
        normalMatrix: simd_float3x3
    ) {
        renderGroundAndModels(
            resource: resource,
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            modelMatrix: modelMatrix,
            viewMatrix: viewMatrix,
            projectionMatrix: projectionMatrix,
            normalMatrix: normalMatrix
        )

        renderWater(
            resource: resource,
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            modelMatrix: modelMatrix,
            viewMatrix: viewMatrix,
            projectionMatrix: projectionMatrix
        )
    }

    public func renderGroundAndModels(
        resource: WorldRenderResource,
        atTime time: TimeInterval,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        modelMatrix: simd_float4x4,
        viewMatrix: simd_float4x4,
        projectionMatrix: simd_float4x4,
        normalMatrix: simd_float3x3
    ) {
        groundRenderer.render(
            resource: resource.groundResource,
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            modelMatrix: modelMatrix,
            viewMatrix: viewMatrix,
            projectionMatrix: projectionMatrix,
            normalMatrix: normalMatrix
        )

        modelRenderer.render(
            resources: resource.modelResources,
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            modelMatrix: modelMatrix,
            viewMatrix: viewMatrix,
            projectionMatrix: projectionMatrix,
            normalMatrix: normalMatrix
        )
    }

    public func renderWater(
        resource: WorldRenderResource,
        atTime time: TimeInterval,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        modelMatrix: simd_float4x4,
        viewMatrix: simd_float4x4,
        projectionMatrix: simd_float4x4
    ) {
        waterRenderer.render(
            resource: resource.waterResource,
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            modelMatrix: modelMatrix,
            viewMatrix: viewMatrix,
            projectionMatrix: projectionMatrix
        )
    }

    public func renderEffects(
        resource: WorldRenderResource,
        atTime time: TimeInterval,
        beforeEntities: Bool? = nil,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        modelMatrix: simd_float4x4,
        viewMatrix: simd_float4x4,
        projectionMatrix: simd_float4x4,
        cameraAzimuth: Float
    ) {
        for effectResource in resource.effectResources {
            if let beforeEntities, effectResource.rendersBeforeEntities != beforeEntities {
                continue
            }

            if effectResource.isExpired(atTime: time) {
                effectResource.restart(atTime: time)
            }

            effectRenderer.render(
                resourceGroup: effectResource,
                atTime: time,
                renderCommandEncoder: renderCommandEncoder,
                modelMatrix: modelMatrix,
                viewMatrix: viewMatrix,
                projectionMatrix: projectionMatrix,
                cameraAzimuth: cameraAzimuth
            )
        }
    }
}
