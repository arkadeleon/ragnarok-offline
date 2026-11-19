//
//  EffectRenderer.swift
//  RagnarokRendering
//
//  Created by Leon Li on 2026/6/30.
//

import Metal
import simd

public final class EffectRenderer {
    public struct RenderPayload {
        public let resource: EffectRenderResource
        public let elapsedTime: TimeInterval
        public let worldPosition: SIMD3<Float>
        public let sourceWorldPosition: SIMD3<Float>?
        public let targetWorldPosition: SIMD3<Float>
        public let fog: Fog
        public let modelMatrix: simd_float4x4
    }

    public let device: any MTLDevice

    private let twoDEffectRenderer: TwoDEffectRenderer
    private let threeDEffectRenderer: ThreeDEffectRenderer
    private let cylinderEffectRenderer: CylinderEffectRenderer
    private let sprEffectRenderer: SPREffectRenderer
    private let strEffectRenderer: STREffectRenderer

    public init(device: any MTLDevice, configuration: RenderConfiguration) throws {
        self.device = device

        twoDEffectRenderer = try TwoDEffectRenderer(device: device, configuration: configuration)
        threeDEffectRenderer = try ThreeDEffectRenderer(device: device, configuration: configuration)
        cylinderEffectRenderer = try CylinderEffectRenderer(device: device, configuration: configuration)
        sprEffectRenderer = try SPREffectRenderer(device: device, configuration: configuration)
        strEffectRenderer = try STREffectRenderer(device: device, configuration: configuration)
    }

    public func submit(
        resourceGroup: EffectRenderResourceGroup,
        atTime time: TimeInterval,
        attachedWorldPosition: SIMD3<Float>? = nil,
        fog: Fog,
        modelMatrix: simd_float4x4,
        into queue: RenderQueue<EffectRenderer.RenderPayload>
    ) {
        submit(
            resourceGroup: resourceGroup,
            atTime: time,
            attachedWorldPosition: attachedWorldPosition,
            fog: fog,
            modelMatrix: modelMatrix,
            into: queue
        ) { $0 }
    }

    public func submit<Payload>(
        resourceGroup: EffectRenderResourceGroup,
        atTime time: TimeInterval,
        attachedWorldPosition: SIMD3<Float>? = nil,
        fog: Fog,
        modelMatrix: simd_float4x4,
        into queue: RenderQueue<Payload>,
        transform: (EffectRenderer.RenderPayload) -> Payload
    ) {
        let elapsedTime = time - resourceGroup.creationTime - resourceGroup.delay
        let targetWorldPosition = resourceGroup.worldPosition
        let sourceWorldPosition = resourceGroup.sourceWorldPosition

        for resource in resourceGroup.resources {
            let bucket: RenderPassBucket = if resource.rendersBeforeEntities {
                .groundDecal
            } else if resource.isOverlay {
                .overlay
            } else {
                .translucent
            }
            let worldPosition = resolveWorldPosition(
                for: resource,
                baseWorldPosition: targetWorldPosition,
                attachedWorldPosition: attachedWorldPosition
            )
            let payload = EffectRenderer.RenderPayload(
                resource: resource,
                elapsedTime: elapsedTime,
                worldPosition: worldPosition,
                sourceWorldPosition: sourceWorldPosition,
                targetWorldPosition: targetWorldPosition,
                fog: fog,
                modelMatrix: modelMatrix
            )
            queue.submit(
                bucket: bucket,
                worldCenter: worldPosition,
                modelMatrix: modelMatrix,
                payload: transform(payload)
            )
        }
    }

    public func render(
        payload: EffectRenderer.RenderPayload,
        camera: RenderCamera,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        render(
            resource: payload.resource,
            elapsedTime: payload.elapsedTime,
            worldPosition: payload.worldPosition,
            sourceWorldPosition: payload.sourceWorldPosition,
            targetWorldPosition: payload.targetWorldPosition,
            fog: payload.fog,
            modelMatrix: payload.modelMatrix,
            camera: camera,
            renderCommandEncoder: renderCommandEncoder
        )
    }

    private func resolveWorldPosition(
        for resource: EffectRenderResource,
        baseWorldPosition: SIMD3<Float>,
        attachedWorldPosition: SIMD3<Float>?
    ) -> SIMD3<Float> {
        let attachedToTarget: Bool = switch resource {
        case .`2D`(let resource):
            resource.definition.attachedToTarget
        case .`3D`(let resource):
            resource.definition.attachedToTarget
        case .cylinder(let resource):
            resource.definition.attachedToTarget
        case .spr(let resource):
            resource.definition.attachedToTarget
        case .str(let resource):
            resource.definition?.attachedToTarget == true
        }
        return attachedToTarget ? (attachedWorldPosition ?? baseWorldPosition) : baseWorldPosition
    }

    private func render(
        resource: EffectRenderResource,
        elapsedTime: TimeInterval,
        worldPosition: SIMD3<Float>,
        sourceWorldPosition: SIMD3<Float>?,
        targetWorldPosition: SIMD3<Float>,
        fog: Fog,
        modelMatrix: simd_float4x4,
        camera: RenderCamera,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        switch resource {
        case .`2D`(let resource):
            twoDEffectRenderer.render(
                resource: resource,
                elapsedTime: elapsedTime,
                worldPosition: worldPosition,
                fog: fog,
                modelMatrix: modelMatrix,
                camera: camera,
                renderCommandEncoder: renderCommandEncoder
            )
        case .`3D`(let resource):
            threeDEffectRenderer.render(
                resource: resource,
                elapsedTime: elapsedTime,
                worldPosition: worldPosition,
                sourceWorldPosition: sourceWorldPosition,
                targetWorldPosition: targetWorldPosition,
                fog: fog,
                modelMatrix: modelMatrix,
                camera: camera,
                renderCommandEncoder: renderCommandEncoder
            )
        case .cylinder(let resource):
            cylinderEffectRenderer.render(
                resource: resource,
                elapsedTime: elapsedTime,
                worldPosition: worldPosition,
                fog: fog,
                modelMatrix: modelMatrix,
                camera: camera,
                renderCommandEncoder: renderCommandEncoder
            )
        case .spr(let resource):
            sprEffectRenderer.render(
                resource: resource,
                elapsedTime: elapsedTime,
                worldPosition: worldPosition,
                fog: fog,
                modelMatrix: modelMatrix,
                camera: camera,
                renderCommandEncoder: renderCommandEncoder
            )
        case .str(let resource):
            strEffectRenderer.render(
                resource: resource,
                elapsedTime: elapsedTime,
                spritePosition: worldPosition,
                fog: fog,
                modelMatrix: modelMatrix,
                camera: camera,
                renderCommandEncoder: renderCommandEncoder
            )
        }
    }
}
