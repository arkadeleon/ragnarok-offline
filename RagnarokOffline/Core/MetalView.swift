//
//  MetalView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/25.
//

import SwiftUI
import MetalKit
import RORenderers

struct MetalView: UIViewRepresentable {
    var renderer: Renderer

    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.isOpaque = false
        mtkView.delegate = renderer
        mtkView.device = renderer.device
        mtkView.colorPixelFormat = renderer.colorPixelFormat
        mtkView.depthStencilPixelFormat = renderer.depthStencilPixelFormat
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        return mtkView
    }

    func updateUIView(_ mtkView: MTKView, context: Context) {
        mtkView.delegate = renderer
    }
}
