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

    private let effect2DRenderer: Effect2DRenderer
    private let effect3DRenderer: Effect3DRenderer
    private let cylinderEffectRenderer: CylinderEffectRenderer
    private let sprEffectRenderer: SPREffectRenderer
    private let strEffectRenderer: STREffectRenderer

    public init(device: any MTLDevice) throws {
        self.device = device

        effect2DRenderer = try Effect2DRenderer(device: device)
        effect3DRenderer = try Effect3DRenderer(device: device)
        cylinderEffectRenderer = try CylinderEffectRenderer(device: device)
        sprEffectRenderer = try SPREffectRenderer(device: device)
        strEffectRenderer = try STREffectRenderer(device: device)
    }

    public func render(
        resourceGroup: EffectRenderResourceGroup,
        atTime time: TimeInterval,
        attachedWorldPosition: SIMD3<Float>? = nil,
        renderCommandEncoder: any MTLRenderCommandEncoder,
        modelMatrix: simd_float4x4,
        viewMatrix: simd_float4x4,
        projectionMatrix: simd_float4x4,
        cameraAzimuth: Float
    ) {
        let worldPosition = resourceGroup.worldPosition
        let elapsedTime = time - resourceGroup.creationTime - resourceGroup.delay
        for resource in resourceGroup.resources {
            switch resource {
            case .`2D`(let resource):
                let worldPosition = resource.definition.attachedToTarget ? attachedWorldPosition ?? worldPosition : worldPosition
                effect2DRenderer.render(
                    resource: resource,
                    elapsedTime: elapsedTime,
                    worldPosition: worldPosition,
                    renderCommandEncoder: renderCommandEncoder,
                    viewMatrix: viewMatrix,
                    projectionMatrix: projectionMatrix,
                    cameraAzimuth: cameraAzimuth
                )
            case .`3D`(let resource):
                let worldPosition = resource.definition.attachedToTarget ? attachedWorldPosition ?? worldPosition : worldPosition
                effect3DRenderer.render(
                    resource: resource,
                    elapsedTime: elapsedTime,
                    worldPosition: worldPosition,
                    renderCommandEncoder: renderCommandEncoder,
                    viewMatrix: viewMatrix,
                    projectionMatrix: projectionMatrix,
                    cameraAzimuth: cameraAzimuth
                )
            case .cylinder(let resource):
                let worldPosition = resource.definition.attachedToTarget ? attachedWorldPosition ?? worldPosition : worldPosition
                cylinderEffectRenderer.render(
                    resource: resource,
                    elapsedTime: elapsedTime,
                    worldPosition: worldPosition,
                    renderCommandEncoder: renderCommandEncoder,
                    viewMatrix: viewMatrix,
                    projectionMatrix: projectionMatrix,
                    cameraAzimuth: cameraAzimuth
                )
            case .spr(let resource):
                let worldPosition = resource.definition.attachedToTarget ? attachedWorldPosition ?? worldPosition : worldPosition
                sprEffectRenderer.render(
                    resource: resource,
                    elapsedTime: elapsedTime,
                    worldPosition: worldPosition,
                    renderCommandEncoder: renderCommandEncoder,
                    viewMatrix: viewMatrix,
                    projectionMatrix: projectionMatrix
                )
            case .str(let resource):
                let worldPosition = resource.definition?.attachedToTarget == true ? attachedWorldPosition ?? worldPosition : worldPosition
                strEffectRenderer.render(
                    resource: resource,
                    elapsedTime: elapsedTime,
                    spritePosition: worldPosition,
                    renderCommandEncoder: renderCommandEncoder,
                    modelMatrix: modelMatrix,
                    viewMatrix: viewMatrix,
                    projectionMatrix: projectionMatrix
                )
            }
        }
    }
}
