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
        cameraParameters: CameraParameters
    ) {
        renderGroundAndModels(
            resource: resource,
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            cameraParameters: cameraParameters
        )

        renderWater(
            resource: resource,
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            cameraParameters: cameraParameters
        )
    }

    public func renderGroundAndModels(
        resource: WorldRenderResource,
        atTime time: TimeInterval,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        cameraParameters: CameraParameters
    ) {
        groundRenderer.render(
            resource: resource.groundResource,
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            cameraParameters: cameraParameters
        )

        modelRenderer.render(
            resources: resource.modelResources,
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            cameraParameters: cameraParameters
        )
    }

    public func renderWater(
        resource: WorldRenderResource,
        atTime time: TimeInterval,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        cameraParameters: CameraParameters
    ) {
        waterRenderer.render(
            resource: resource.waterResource,
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            cameraParameters: cameraParameters
        )
    }

    public func renderEffects(
        resource: WorldRenderResource,
        atTime time: TimeInterval,
        beforeEntities: Bool? = nil,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        cameraParameters: CameraParameters
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
                cameraParameters: cameraParameters
            )
        }
    }
}
