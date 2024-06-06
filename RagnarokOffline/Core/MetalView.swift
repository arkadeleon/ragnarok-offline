//
//  MetalView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/25.
//

import MetalKit
import SwiftUI
import RORenderers

struct MetalViewContainer: UIViewRepresentable {
    var renderer: any Renderer

    func makeUIView(context: Context) -> MetalView {
        MetalView(renderer: renderer)
    }

    func updateUIView(_ metalView: MetalView, context: Context) {
    }
}

class MetalView: UIView, MTKViewDelegate {
    let renderer: any Renderer
    let commandQueue: any MTLCommandQueue

    private var mtkView: MTKView!

    init(renderer: any Renderer) {
        self.renderer = renderer

        commandQueue = renderer.device.makeCommandQueue()!

        super.init(frame: .zero)

        mtkView = MTKView()
        mtkView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mtkView.isOpaque = false
        mtkView.delegate = self
        mtkView.device = renderer.device
        mtkView.colorPixelFormat = renderer.colorPixelFormat
        mtkView.depthStencilPixelFormat = renderer.depthStencilPixelFormat
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        addSubview(mtkView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }

    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }

        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor
        else {
            return
        }

        let time = CACurrentMediaTime()

        renderer.render(atTime: time, viewport: view.bounds, commandBuffer: commandBuffer, renderPassDescriptor: renderPassDescriptor)

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
