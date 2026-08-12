//
//  RSMRenderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/7/15.
//

import Foundation
import Metal
import RagnarokCore
import RagnarokRenderAssets
import RagnarokRendering
import simd

public class RSMFilePreviewRenderer: Renderer {
    public let device: any MTLDevice

    let modelBoundingBox: RSMModelBoundingBox
    let modelResource: RSMModelRenderResource
    let modelRenderer: RSMModelRenderer

    public let camera = Camera()

    public init(device: any MTLDevice, asset: RSMModelRenderAsset) throws {
        self.device = device

        modelBoundingBox = asset.boundingBox
        modelResource = RSMModelRenderResource(device: device, asset: asset, light: .preview)
        modelRenderer = try RSMModelRenderer(device: device)
    }

    public func render(frame: RenderFrame) {
        let renderPassDescriptor = frame.renderPassDescriptor
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.depthAttachment.clearDepth = 1

        let scale = 2 / modelBoundingBox.range.max()

        var modelMatrix = matrix_identity_float4x4
        modelMatrix = matrix_scale(modelMatrix, [scale, scale, scale])
        modelMatrix = matrix_rotate(modelMatrix, radians(-15), [1, 0, 0])
        modelMatrix = matrix_rotate(modelMatrix, Float(radians(frame.time.truncatingRemainder(dividingBy: 8) * 360 / 8)), [0, 1, 0])

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

            modelRenderer.render(
                resources: [modelResource],
                atTime: frame.time,
                renderCommandEncoder: renderCommandEncoder,
                cameraParameters: cameraParameters
            )
        }

        renderCommandEncoder.endEncoding()
    }
}
