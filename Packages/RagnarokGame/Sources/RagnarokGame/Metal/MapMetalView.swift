//
//  MapMetalView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/22.
//

#if os(iOS) || os(macOS)

import MetalKit
import SwiftUI

struct MapMetalView: View {
    var scene: MapScene
    var overlay: MapSceneOverlay?

    var body: some View {
        if let backend = scene.renderBackend as? MetalMapBackend {
            MapMetalViewContainer(scene: scene, overlay: overlay, backend: backend)
        } else {
            EmptyView()
        }
    }
}

#if canImport(UIKit)

private struct MapMetalViewContainer: UIViewRepresentable {
    var scene: MapScene
    var overlay: MapSceneOverlay?
    var backend: MetalMapBackend

    func makeUIView(context: Context) -> MapMTKHostView {
        MapMTKHostView(scene: scene, backend: backend)
    }

    func updateUIView(_ view: MapMTKHostView, context: Context) {
        view.update(scene: scene)
        backend.overlay = overlay
    }
}

#elseif canImport(AppKit)

private struct MapMetalViewContainer: NSViewRepresentable {
    var scene: MapScene
    var overlay: MapSceneOverlay?
    var backend: MetalMapBackend

    func makeNSView(context: Context) -> MapMTKHostView {
        MapMTKHostView(scene: scene, backend: backend)
    }

    func updateNSView(_ view: MapMTKHostView, context: Context) {
        view.update(scene: scene)
        backend.overlay = overlay
    }
}

#endif

#if canImport(UIKit)
private typealias PlatformView = UIView
#elseif canImport(AppKit)
private typealias PlatformView = NSView
#endif

private final class MapMTKHostView: PlatformView, MTKViewDelegate {
    private weak var scene: MapScene?
    private let backend: MetalMapBackend
    private let commandQueue: any MTLCommandQueue
    private let renderer: MapRuntimeRenderer
    private let mtkView: MTKView

    private var baseAzimuth: Float = 0
    private var baseElevation: Float = 0
    private var baseDistance: Float = 0

    init(scene: MapScene, backend: MetalMapBackend) {
        self.scene = scene
        self.backend = backend
        self.renderer = backend.renderer
        guard let commandQueue = renderer.device.makeCommandQueue() else {
            fatalError("MapMTKHostView: failed to create Metal command queue")
        }
        self.commandQueue = commandQueue
        self.mtkView = MTKView(frame: .zero, device: renderer.device)

        super.init(frame: .zero)

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

        mtkView.frame = bounds
        addSubview(mtkView)

        configureGestures()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(scene: MapScene) {
        self.scene = scene
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

        backend.prepareFrame()

        renderer.render(
            atTime: CACurrentMediaTime(),
            viewport: view.bounds,
            commandBuffer: commandBuffer,
            renderPassDescriptor: renderPassDescriptor
        )

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    private func configureGestures() {
        #if canImport(UIKit)
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        mtkView.addGestureRecognizer(doubleTapGestureRecognizer)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
        mtkView.addGestureRecognizer(tapGestureRecognizer)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        mtkView.addGestureRecognizer(panGestureRecognizer)

        let twoFingerPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleTwoFingerPan(_:)))
        twoFingerPanGestureRecognizer.minimumNumberOfTouches = 2
        mtkView.addGestureRecognizer(twoFingerPanGestureRecognizer)

        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        mtkView.addGestureRecognizer(pinchGestureRecognizer)
        #elseif canImport(AppKit)
        let panGestureRecognizer = NSPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        mtkView.addGestureRecognizer(panGestureRecognizer)

        let magnificationGestureRecognizer = NSMagnificationGestureRecognizer(target: self, action: #selector(handleMagnification(_:)))
        mtkView.addGestureRecognizer(magnificationGestureRecognizer)
        #endif
    }
}

#if canImport(UIKit)
private extension MapMTKHostView {
    @objc func handleDoubleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let scene else {
            return
        }
        scene.resetCamera()
        baseAzimuth = scene.cameraState.azimuth
        baseElevation = scene.cameraState.elevation
    }

    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let scene else {
            return
        }

        let point = gestureRecognizer.location(in: mtkView)
        if let result = backend.hitTest(at: point) {
            scene.handleInteraction(result)
        }
    }

    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let scene else {
            return
        }

        switch gestureRecognizer.state {
        case .began:
            baseAzimuth = scene.cameraState.azimuth
        case .changed:
            let azimuth = baseAzimuth + Float(gestureRecognizer.translation(in: mtkView).x) * 0.01
            scene.cameraState.azimuth = azimuth.truncatingRemainder(dividingBy: .pi * 2)
        default:
            break
        }
    }

    @objc func handleTwoFingerPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let scene else {
            return
        }

        switch gestureRecognizer.state {
        case .began:
            baseElevation = scene.cameraState.elevation
        case .changed:
            var elevation = baseElevation + Float(gestureRecognizer.translation(in: mtkView).y) * 0.01
            elevation = max(elevation, .pi / 12)
            elevation = min(elevation, .pi / 3)
            scene.cameraState.elevation = elevation
        default:
            break
        }
    }

    @objc func handlePinch(_ gestureRecognizer: UIPinchGestureRecognizer) {
        guard let scene else {
            return
        }

        switch gestureRecognizer.state {
        case .began:
            baseDistance = scene.cameraState.distance
        case .changed:
            var distance = baseDistance * Float(1 / gestureRecognizer.scale)
            distance = max(distance, 3)
            distance = min(distance, 120)
            scene.cameraState.distance = distance
        default:
            break
        }
    }
}
#elseif canImport(AppKit)
private extension MapMTKHostView {
    override func mouseDown(with event: NSEvent) {
        var point = mtkView.convert(event.locationInWindow, from: nil)
        // NSView has bottom-left origin; flip to top-left for hit testing.
        point.y = mtkView.bounds.height - point.y
        if let result = backend.hitTest(at: point) {
            scene?.handleInteraction(result)
        }
    }

    @objc func handlePan(_ gestureRecognizer: NSPanGestureRecognizer) {
        guard let scene else {
            return
        }

        switch gestureRecognizer.state {
        case .began:
            baseAzimuth = scene.cameraState.azimuth
            baseElevation = scene.cameraState.elevation
        case .changed:
            let azimuth = baseAzimuth + Float(gestureRecognizer.translation(in: mtkView).x) * 0.01
            scene.cameraState.azimuth = azimuth.truncatingRemainder(dividingBy: .pi * 2)

            var elevation = baseElevation - Float(gestureRecognizer.translation(in: mtkView).y) * 0.01
            elevation = max(elevation, .pi / 12)
            elevation = min(elevation, .pi / 3)
            scene.cameraState.elevation = elevation
        default:
            break
        }
    }

    @objc func handleMagnification(_ gestureRecognizer: NSMagnificationGestureRecognizer) {
        guard let scene else {
            return
        }

        switch gestureRecognizer.state {
        case .began:
            baseDistance = scene.cameraState.distance
        case .changed:
            var scale = 1 + gestureRecognizer.magnification
            scale = max(scale, .leastNonzeroMagnitude)

            var distance = baseDistance * Float(1 / scale)
            distance = max(distance, 3)
            distance = min(distance, 120)
            scene.cameraState.distance = distance
        default:
            break
        }
    }
}
#endif

#endif
