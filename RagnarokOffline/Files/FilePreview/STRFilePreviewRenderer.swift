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
import RagnarokRenderers
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
            textureImages: textureImages,
            spritePosition: .zero
        )
        creationTime = CACurrentMediaTime()

        camera.fovy = 15
        camera.nearZ = 1
        camera.farZ = 1000
        camera.defaultDistance = 75
        camera.minimumDistance = 50
        camera.maximumDistance = 100
    }

    public func render(
        atTime time: TimeInterval,
        viewport: CGRect,
        commandBuffer: any MTLCommandBuffer,
        renderPassDescriptor: MTLRenderPassDescriptor
    ) {
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.depthAttachment.clearDepth = 1

        camera.update(size: viewport.size)

        var modelMatrix = matrix_identity_float4x4
        modelMatrix = matrix_translate(modelMatrix, [0, -3, 0])

        let viewMatrix = camera.viewMatrix
        let projectionMatrix = camera.projectionMatrix

        guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        effectRenderer.render(
            resource: effectResource,
            elapsedTime: time - creationTime,
            renderCommandEncoder: renderCommandEncoder,
            modelMatrix: modelMatrix,
            viewMatrix: viewMatrix,
            projectionMatrix: projectionMatrix
        )

        renderCommandEncoder.endEncoding()
    }
}
