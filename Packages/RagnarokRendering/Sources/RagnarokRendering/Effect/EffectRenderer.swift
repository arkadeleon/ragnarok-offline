//
//  EffectRenderer.swift
//  RagnarokRendering
//
//  Created by Leon Li on 2026/6/30.
//

import Metal
import simd

public final class EffectRenderer {
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

    public func render(
        resourceGroup: EffectRenderResourceGroup,
        atTime time: TimeInterval,
        attachedWorldPosition: SIMD3<Float>? = nil,
        fog: Fog,
        modelMatrix: simd_float4x4,
        camera: RenderCamera,
        renderCommandEncoder: any MTLRenderCommandEncoder
    ) {
        let worldPosition = resourceGroup.worldPosition
        let elapsedTime = time - resourceGroup.creationTime - resourceGroup.delay
        for resource in resourceGroup.resources {
            switch resource {
            case .`2D`(let resource):
                let worldPosition = resource.definition.attachedToTarget ? attachedWorldPosition ?? worldPosition : worldPosition
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
                let worldPosition = resource.definition.attachedToTarget ? attachedWorldPosition ?? worldPosition : worldPosition
                threeDEffectRenderer.render(
                    resource: resource,
                    elapsedTime: elapsedTime,
                    worldPosition: worldPosition,
                    sourceWorldPosition: resourceGroup.sourceWorldPosition,
                    targetWorldPosition: resourceGroup.worldPosition,
                    fog: fog,
                    modelMatrix: modelMatrix,
                    camera: camera,
                    renderCommandEncoder: renderCommandEncoder
                )
            case .cylinder(let resource):
                let worldPosition = resource.definition.attachedToTarget ? attachedWorldPosition ?? worldPosition : worldPosition
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
                let worldPosition = resource.definition.attachedToTarget ? attachedWorldPosition ?? worldPosition : worldPosition
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
                let worldPosition = resource.definition?.attachedToTarget == true ? attachedWorldPosition ?? worldPosition : worldPosition
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
}
