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
    public enum RenderPayload {
        case ground(resource: GroundRenderResource, time: TimeInterval, fog: Fog, modelMatrix: simd_float4x4)
        case models(resources: [RSMModelRenderResource], time: TimeInterval, fog: Fog, modelMatrix: simd_float4x4)
        case water(resource: WaterRenderResource, time: TimeInterval, fog: Fog, modelMatrix: simd_float4x4)
    }

    public let device: any MTLDevice

    private let groundRenderer: GroundRenderer
    private let waterRenderer: WaterRenderer
    private let modelRenderer: RSMModelRenderer

    public init(device: any MTLDevice, configuration: RenderConfiguration) throws {
        self.device = device

        groundRenderer = try GroundRenderer(device: device, configuration: configuration)
        waterRenderer = try WaterRenderer(device: device, configuration: configuration)
        modelRenderer = try RSMModelRenderer(device: device, configuration: configuration)
    }

    public func submit(
        resource: WorldRenderResource,
        atTime time: TimeInterval,
        fog: Fog,
        modelMatrix: simd_float4x4,
        includeWater: Bool = true,
        into queue: RenderQueue<WorldRenderer.RenderPayload>
    ) {
        submit(
            resource: resource,
            atTime: time,
            fog: fog,
            modelMatrix: modelMatrix,
            includeWater: includeWater,
            into: queue
        ) { $0 }
    }

    public func submit<Payload>(
        resource: WorldRenderResource,
        atTime time: TimeInterval,
        fog: Fog,
        modelMatrix: simd_float4x4,
        includeWater: Bool = true,
        into queue: RenderQueue<Payload>,
        transform: (WorldRenderer.RenderPayload) -> Payload
    ) {
        queue.submit(
            bucket: .opaque,
            modelMatrix: modelMatrix,
            payload: transform(.ground(resource: resource.groundResource, time: time, fog: fog, modelMatrix: modelMatrix))
        )

        queue.submit(
            bucket: .opaque,
            modelMatrix: modelMatrix,
            payload: transform(.models(resources: resource.modelResources, time: time, fog: fog, modelMatrix: modelMatrix))
        )

        if includeWater, resource.hasWater {
            queue.submit(
                bucket: .translucent,
                worldCenter: resource.waterResource.worldCenter,
                modelMatrix: modelMatrix,
                payload: transform(.water(resource: resource.waterResource, time: time, fog: fog, modelMatrix: modelMatrix))
            )
        }

    }

    public func render(
        payload: WorldRenderer.RenderPayload,
        camera: RenderCamera,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        switch payload {
        case .ground(let resource, let time, let fog, let modelMatrix):
            groundRenderer.render(
                resource: resource,
                atTime: time,
                fog: fog,
                modelMatrix: modelMatrix,
                camera: camera,
                renderCommandEncoder: renderCommandEncoder
            )
        case .models(let resources, let time, let fog, let modelMatrix):
            modelRenderer.render(
                resources: resources,
                atTime: time,
                fog: fog,
                modelMatrix: modelMatrix,
                camera: camera,
                renderCommandEncoder: renderCommandEncoder
            )
        case .water(let resource, let time, let fog, let modelMatrix):
            waterRenderer.render(
                resource: resource,
                atTime: time,
                fog: fog,
                modelMatrix: modelMatrix,
                camera: camera,
                renderCommandEncoder: renderCommandEncoder
            )
        }
    }

    public func renderWaterDepth(
        resource: WorldRenderResource,
        atTime time: TimeInterval,
        modelMatrix: simd_float4x4,
        camera: RenderCamera,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        waterRenderer.renderDepth(
            resource: resource.waterResource,
            atTime: time,
            modelMatrix: modelMatrix,
            camera: camera,
            renderCommandEncoder: renderCommandEncoder
        )
    }

    public func renderWater(
        resource: WorldRenderResource,
        atTime time: TimeInterval,
        fog: Fog,
        modelMatrix: simd_float4x4,
        camera: RenderCamera,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        waterRenderer.render(
            resource: resource.waterResource,
            atTime: time,
            fog: fog,
            modelMatrix: modelMatrix,
            camera: camera,
            renderCommandEncoder: renderCommandEncoder
        )
    }
}
