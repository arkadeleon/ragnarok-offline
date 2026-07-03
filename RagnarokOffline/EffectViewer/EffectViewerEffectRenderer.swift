//
//  EffectViewerEffectRenderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/6/29.
//

import CoreGraphics
import Foundation
import Metal
import QuartzCore
import RagnarokCore
import RagnarokEffects
import RagnarokFileFormats
import RagnarokRenderAssets
import RagnarokRenderers
import simd

class EffectViewerEffectRenderer: Renderer {
    let device: any MTLDevice

    private let effectRenderer: EffectRenderer
    private var effectResources: [EffectRenderResource] = []

    let camera: OrbitalCamera

    init(device: any MTLDevice, assets: [EffectAsset]) throws {
        self.device = device

        effectRenderer = try EffectRenderer(device: device)

        camera = OrbitalCamera(distance: 20)
        camera.fovy = 45
        camera.nearZ = 1
        camera.farZ = 1000
        camera.elevation = radians(20)
        camera.minimumDistance = 8
        camera.maximumDistance = 80
        camera.target = [0, 1.5, 0]

        buildResources(from: assets, atTime: CACurrentMediaTime())
    }

    private func buildResources(from assets: [EffectAsset], atTime time: TimeInterval) {
        var resources: [EffectRenderResource] = []

        for asset in assets {
            switch asset {
            case .`3D`(let asset):
                let definition = asset.definition
                for duplicateID in 0..<max(definition.duplicate.count, 1) {
                    let delay = definition.delay(duplicateID: duplicateID)
                    let resource = Effect3DRenderResource(
                        device: device,
                        asset: asset,
                        worldPosition: .zero,
                        creationTime: time,
                        delay: delay,
                        duplicateID: duplicateID
                    )
                    resources.append(.`3D`(resource))
                }
            case .cylinder(let asset):
                let definition = asset.definition
                for duplicateID in 0..<max(definition.duplicate.count, 1) {
                    let delay = definition.delay(duplicateID: duplicateID)
                    let resource = CylinderEffectRenderResource(
                        device: device,
                        asset: asset,
                        worldPosition: .zero,
                        creationTime: time,
                        delay: delay
                    )
                    resources.append(.cylinder(resource))
                }
            case .spr(let asset):
                let resource = SPREffectRenderResource(
                    device: device,
                    asset: asset,
                    worldPosition: .zero,
                    creationTime: time
                )
                resources.append(.spr(resource))
            case .str(let asset):
                let resource = STREffectRenderResource(
                    device: device,
                    asset: asset,
                    spritePosition: .zero,
                    creationTime: time
                )
                resources.append(.str(resource))
            }
        }

        effectResources = resources
    }

    func render(
        atTime time: TimeInterval,
        viewport: CGRect,
        commandBuffer: any MTLCommandBuffer,
        renderPassDescriptor: MTLRenderPassDescriptor
    ) {
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.depthAttachment.clearDepth = 1

        camera.update(atTime: time)
        camera.update(size: viewport.size)

        let viewMatrix = camera.viewMatrix
        let projectionMatrix = camera.projectionMatrix
        let cameraAzimuth = camera.azimuth

        var modelMatrix = matrix_identity_float4x4
        modelMatrix = matrix_rotate(modelMatrix, radians(-180), [1, 0, 0])

        guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        for resource in effectResources {
            effectRenderer.render(
                resource: resource,
                atTime: time,
                renderCommandEncoder: renderCommandEncoder,
                modelMatrix: modelMatrix,
                viewMatrix: viewMatrix,
                projectionMatrix: projectionMatrix,
                cameraAzimuth: cameraAzimuth
            )
        }

        renderCommandEncoder.endEncoding()
    }

    func isComplete(atTime time: TimeInterval) -> Bool {
        !effectResources.isEmpty && effectResources.allSatisfy({ $0.isExpired(atTime: time) })
    }
}
