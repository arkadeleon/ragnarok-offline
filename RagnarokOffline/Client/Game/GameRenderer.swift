//
//  GameRenderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/22.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Metal
import MetalKit

class GameRenderer: NSObject {

    let render: (MTLRenderCommandEncoder) -> Void

    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let colorPixelFormat: MTLPixelFormat
    let depthStencilPixelFormat: MTLPixelFormat
    let renderPipelineState: MTLRenderPipelineState
    let depthStencilState: MTLDepthStencilState

    init(render: @escaping (MTLRenderCommandEncoder) -> Void) {
        self.render = render

        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device.makeCommandQueue()!

        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()

        let library = device.makeDefaultLibrary()!
        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexShader")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")

        colorPixelFormat = .bgra8Unorm
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = colorPixelFormat

        renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha

        depthStencilPixelFormat = .depth32Float
        renderPipelineDescriptor.depthAttachmentPixelFormat = depthStencilPixelFormat

        renderPipelineState = try! device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .lessEqual
        depthStencilDescriptor.isDepthWriteEnabled = true

        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)!

        super.init()
    }
}

extension GameRenderer: MTKViewDelegate {

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

    }

    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }

        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
            return
        }

        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store

        renderPassDescriptor.depthAttachment.clearDepth = 1

        guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)

        render(renderCommandEncoder)

        renderCommandEncoder.endEncoding()

        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
}
