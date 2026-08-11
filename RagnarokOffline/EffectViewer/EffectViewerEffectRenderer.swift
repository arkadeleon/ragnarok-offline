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
import RagnarokFileFormats
import RagnarokRenderAssets
import RagnarokRendering
import simd

class EffectViewerEffectRenderer: Renderer {
    let device: any MTLDevice

    private let effectRenderer: EffectRenderer
    private let effectResourceGroup: EffectRenderResourceGroup

    let camera: OrbitalCamera

    init(device: any MTLDevice, assetGroup: EffectAssetGroup) throws {
        self.device = device

        effectRenderer = try EffectRenderer(device: device)
        effectResourceGroup = EffectRenderResourceGroup(
            device: device,
            assetGroup: assetGroup,
            creationTime: CACurrentMediaTime(),
            delay: 0
        )

        camera = OrbitalCamera(distance: 20)
        camera.fovy = 45
        camera.nearZ = 1
        camera.farZ = 1000
        camera.elevation = radians(20)
        camera.minimumDistance = 8
        camera.maximumDistance = 80
        camera.target = [0, 1.5, 0]
    }

    func render(
        atTime time: TimeInterval,
        viewport: CGRect,
        commandBuffer: any MTLCommandBuffer,
        renderPassDescriptor: MTLRenderPassDescriptor
    ) {
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.depthAttachment.clearDepth = 1

        camera.update(atTime: time)
        camera.update(size: viewport.size)

        var modelMatrix = matrix_identity_float4x4
        modelMatrix = matrix_rotate(modelMatrix, radians(-180), [1, 0, 0])

        let cameraParameters = CameraParameters(
            modelMatrix: modelMatrix,
            viewMatrix: camera.viewMatrix,
            projectionMatrix: camera.projectionMatrix,
            cameraAzimuth: camera.azimuth,
            cameraElevation: camera.elevation
        )

        guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        effectRenderer.render(
            resourceGroup: effectResourceGroup,
            atTime: time,
            renderCommandEncoder: renderCommandEncoder,
            cameraParameters: cameraParameters
        )

        renderCommandEncoder.endEncoding()
    }

    func isComplete(atTime time: TimeInterval) -> Bool {
        effectResourceGroup.isExpired(atTime: time)
    }
}
