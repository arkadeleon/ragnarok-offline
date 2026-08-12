//
//  WorldRenderer.swift
//  RagnarokRendering
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

    public init(device: any MTLDevice, configuration: RenderConfiguration) throws {
        self.device = device

        groundRenderer = try GroundRenderer(device: device, configuration: configuration)
        waterRenderer = try WaterRenderer(device: device, configuration: configuration)
        modelRenderer = try RSMModelRenderer(device: device, configuration: configuration)
        effectRenderer = try EffectRenderer(device: device, configuration: configuration)
    }

    public func render(
        resource: WorldRenderResource,
        atTime time: TimeInterval,
        modelMatrix: simd_float4x4,
        camera: RenderCamera,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        renderGroundAndModels(
            resource: resource,
            atTime: time,
            modelMatrix: modelMatrix,
            camera: camera,
            renderCommandEncoder: renderCommandEncoder
        )

        renderWater(
            resource: resource,
            atTime: time,
            modelMatrix: modelMatrix,
            camera: camera,
            renderCommandEncoder: renderCommandEncoder
        )
    }

    public func renderGroundAndModels(
        resource: WorldRenderResource,
        atTime time: TimeInterval,
        modelMatrix: simd_float4x4,
        camera: RenderCamera,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        groundRenderer.render(
            resource: resource.groundResource,
            atTime: time,
            modelMatrix: modelMatrix,
            camera: camera,
            renderCommandEncoder: renderCommandEncoder
        )

        modelRenderer.render(
            resources: resource.modelResources,
            atTime: time,
            modelMatrix: modelMatrix,
            camera: camera,
            renderCommandEncoder: renderCommandEncoder
        )
    }

    public func renderWater(
        resource: WorldRenderResource,
        atTime time: TimeInterval,
        modelMatrix: simd_float4x4,
        camera: RenderCamera,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        waterRenderer.render(
            resource: resource.waterResource,
            atTime: time,
            modelMatrix: modelMatrix,
            camera: camera,
            renderCommandEncoder: renderCommandEncoder
        )
    }

    public func renderEffects(
        resource: WorldRenderResource,
        atTime time: TimeInterval,
        beforeEntities: Bool? = nil,
        modelMatrix: simd_float4x4,
        camera: RenderCamera,
        renderCommandEncoder: any MTLRenderCommandEncoder
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
                modelMatrix: modelMatrix,
                camera: camera,
                renderCommandEncoder: renderCommandEncoder
            )
        }
    }
}
