//
//  MetalView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/5/22.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI
import MetalKit

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
