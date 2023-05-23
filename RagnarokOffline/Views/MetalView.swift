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
        mtkView.delegate = renderer
        mtkView.device = renderer.device
        mtkView.colorPixelFormat = .bgra8Unorm
        mtkView.depthStencilPixelFormat = .depth32Float
        return mtkView
    }

    func updateUIView(_ mtkView: MTKView, context: Context) {
        mtkView.delegate = renderer
    }
}
