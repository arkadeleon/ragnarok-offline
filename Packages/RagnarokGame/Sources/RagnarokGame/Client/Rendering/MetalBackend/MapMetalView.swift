//
//  MapMetalView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/22.
//

#if os(iOS) || os(macOS)

import MetalKit
import RagnarokRenderers
import SwiftUI

struct MapMetalView: View {
    var scene: MapScene
    var overlay: MapSceneOverlay?

    @State private var backend = MetalMapBackend()

    var body: some View {
        MapMetalViewContainer(renderer: backend.renderer)
            .onAppear {
                backend.attach(scene: scene)
            }
            .onDisappear {
                backend.detach()
            }
    }
}

#if canImport(UIKit)

private struct MapMetalViewContainer: UIViewRepresentable {
    var renderer: MapRuntimeRenderer

    func makeUIView(context: Context) -> MapMTKHostView {
        MapMTKHostView(renderer: renderer)
    }

    func updateUIView(_ view: MapMTKHostView, context: Context) {
    }
}

#elseif canImport(AppKit)

private struct MapMetalViewContainer: NSViewRepresentable {
    var renderer: MapRuntimeRenderer

    func makeNSView(context: Context) -> MapMTKHostView {
        MapMTKHostView(renderer: renderer)
    }

    func updateNSView(_ view: MapMTKHostView, context: Context) {
    }
}

#endif

#if canImport(UIKit)
private typealias PlatformView = UIView
#elseif canImport(AppKit)
private typealias PlatformView = NSView
#endif

private final class MapMTKHostView: PlatformView, MTKViewDelegate {
    private let renderer: MapRuntimeRenderer
    private let commandQueue: any MTLCommandQueue

    init(renderer: MapRuntimeRenderer) {
        self.renderer = renderer
        guard let commandQueue = renderer.device.makeCommandQueue() else {
            fatalError("MapMTKHostView: failed to create Metal command queue")
        }
        self.commandQueue = commandQueue

        super.init(frame: .zero)

        let mtkView = MTKView(frame: .zero, device: renderer.device)
        mtkView.delegate = self
        mtkView.colorPixelFormat = renderer.colorPixelFormat
        mtkView.depthStencilPixelFormat = renderer.depthStencilPixelFormat
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)

        #if canImport(UIKit)
        mtkView.isOpaque = false
        mtkView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        #elseif canImport(AppKit)
        mtkView.autoresizingMask = [.width, .height]
        #endif

        addSubview(mtkView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }

    func draw(in view: MTKView) {
        guard
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let drawable = view.currentDrawable,
            let renderPassDescriptor = view.currentRenderPassDescriptor
        else {
            return
        }

        renderer.render(
            atTime: CACurrentMediaTime(),
            viewport: view.bounds,
            commandBuffer: commandBuffer,
            renderPassDescriptor: renderPassDescriptor
        )

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

#endif
