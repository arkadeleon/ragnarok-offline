//
//  GNDFilePreviewRenderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/16.
//

import Foundation
import Metal
import RagnarokCore
import RagnarokRenderAssets
import RagnarokRendering
import simd

class GNDFilePreviewRenderer: Renderer {
    let device: any MTLDevice

    let groundAsset: GroundRenderAsset
    let groundResource: GroundRenderResource
    let groundRenderer: GroundRenderer

    let camera: OrbitalCamera

    init(device: any MTLDevice, asset: GroundRenderAsset) throws {
        self.device = device
        groundAsset = asset

        groundResource = GroundRenderResource(device: device, asset: asset, light: .preview)
        groundRenderer = try GroundRenderer(device: device)

        let defaultDistance = -asset.altitude / 5 + 200
        camera = OrbitalCamera(distance: defaultDistance)
        camera.elevation = .pi / 2
        camera.minimumDistance = defaultDistance - 190
        camera.maximumDistance = defaultDistance + 200
        camera.farZ = 500
    }

    func render(frame: RenderFrame) {
        let renderPassDescriptor = frame.renderPassDescriptor
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.depthAttachment.clearDepth = 1

        camera.update(atTime: frame.time)

        var modelMatrix = matrix_identity_float4x4
        modelMatrix = matrix_rotate(modelMatrix, radians(-180), [1, 0, 0])
        modelMatrix = matrix_translate(modelMatrix, [-Float(groundAsset.width / 2), 0, -Float(groundAsset.height / 2)])

        guard let renderCommandEncoder = frame.commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        for view in frame.views {
            renderCommandEncoder.setViewport(view.viewport)

            camera.update(size: view.size)

            let cameraParameters = CameraParameters(
                modelMatrix: modelMatrix,
                viewMatrix: view.viewMatrix ?? camera.viewMatrix,
                projectionMatrix: view.projectionMatrix ?? camera.projectionMatrix
            )

            groundRenderer.render(
                resource: groundResource,
                atTime: frame.time,
                renderCommandEncoder: renderCommandEncoder,
                cameraParameters: cameraParameters
            )
        }

        renderCommandEncoder.endEncoding()
    }
}
