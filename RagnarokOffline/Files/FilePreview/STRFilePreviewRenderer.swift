//
//  STRFilePreviewRenderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/24.
//

import CoreGraphics
import Foundation
import Metal
import QuartzCore
import RagnarokCore
import RagnarokRenderAssets
import RagnarokRendering
import simd

public class STRFilePreviewRenderer: Renderer {
    public let device: any MTLDevice

    let effectRenderer: STREffectRenderer
    let effectResource: STREffectRenderResource
    let creationTime: TimeInterval

    public let camera = Camera()

    public init(device: any MTLDevice, effect: STREffect, textureImages: [String : CGImage]) throws {
        self.device = device

        effectRenderer = try STREffectRenderer(device: device)
        effectResource = STREffectRenderResource(
            device: device,
            effect: effect,
            textureImages: textureImages
        )
        creationTime = CACurrentMediaTime()

        camera.fovy = 15
        camera.nearZ = 1
        camera.farZ = 1000
        camera.defaultDistance = 75
        camera.minimumDistance = 50
        camera.maximumDistance = 100
    }

    public func makeCamera(atTime time: TimeInterval, viewport: MTLViewport) -> RenderCamera {
        camera.update(size: viewport.size)

        return RenderCamera(
            viewMatrix: camera.viewMatrix,
            projectionMatrix: camera.projectionMatrix
        )
    }

    public func render(frame: RenderFrame) {
        let renderPassDescriptor = frame.renderPassDescriptor
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.depthAttachment.clearDepth = 1

        var modelMatrix = matrix_identity_float4x4
        modelMatrix = matrix_translate(modelMatrix, [0, -3, 0])

        guard let renderCommandEncoder = frame.commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        for view in frame.views {
            renderCommandEncoder.setViewport(view.viewport)

            let cameraParameters = CameraParameters(modelMatrix: modelMatrix, camera: view.camera)

            effectRenderer.render(
                resource: effectResource,
                elapsedTime: frame.time - creationTime,
                spritePosition: .zero,
                renderCommandEncoder: renderCommandEncoder,
                cameraParameters: cameraParameters
            )
        }

        renderCommandEncoder.endEncoding()
    }
}
