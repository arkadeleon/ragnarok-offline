//
//  MetalMapView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/22.
//

import MetalKit
import SwiftUI

#if canImport(UIKit)

struct MetalMapView: UIViewControllerRepresentable {
    var scene: MapScene

    func makeUIViewController(context: Context) -> MetalMapViewController {
        guard let backend = scene.renderBackend as? MetalRenderBackend else {
            preconditionFailure("scene.renderBackend must be a MetalRenderBackend.")
        }
        return MetalMapViewController(scene: scene, backend: backend)
    }

    func updateUIViewController(_ viewController: MetalMapViewController, context: Context) {
        viewController.update(scene: scene)
    }
}

final class MetalMapViewController: UIViewController, MTKViewDelegate {
    private weak var scene: MapScene?
    private let backend: MetalRenderBackend
    private let commandQueue: any MTLCommandQueue
    private let renderer: MetalMapRenderer
    private var mtkView: MTKView!

    private var baseAzimuth: Float = 0
    private var baseElevation: Float = 0
    private var baseDistance: Float = 0

    init(scene: MapScene, backend: MetalRenderBackend) {
        self.scene = scene
        self.backend = backend
        self.renderer = backend.renderer
        guard let commandQueue = renderer.device.makeCommandQueue() else {
            fatalError("MetalMapViewController: failed to create Metal command queue")
        }
        self.commandQueue = commandQueue
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mtkView = MTKView(frame: view.bounds, device: renderer.device)
        mtkView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mtkView.isOpaque = false
        mtkView.delegate = self
        mtkView.colorPixelFormat = renderer.colorPixelFormat
        mtkView.depthStencilPixelFormat = renderer.depthStencilPixelFormat
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        view.addSubview(mtkView)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        mtkView.addGestureRecognizer(tapGestureRecognizer)

        let twoFingerTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTwoFingerTap(_:)))
        twoFingerTapGestureRecognizer.numberOfTouchesRequired = 2
        mtkView.addGestureRecognizer(twoFingerTapGestureRecognizer)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        mtkView.addGestureRecognizer(panGestureRecognizer)

        let twoFingerPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleTwoFingerPan(_:)))
        twoFingerPanGestureRecognizer.minimumNumberOfTouches = 2
        mtkView.addGestureRecognizer(twoFingerPanGestureRecognizer)

        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        mtkView.addGestureRecognizer(pinchGestureRecognizer)
    }

    func update(scene: MapScene) {
        self.scene = scene
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }

    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor else {
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

    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let scene else {
            return
        }

        let point = gestureRecognizer.location(in: mtkView)
        if let result = backend.hitTest(point) {
            scene.handleInteraction(result)
        }
    }

    @objc func handleTwoFingerTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let scene else {
            return
        }
        scene.resetCamera()
        baseAzimuth = scene.cameraState.azimuth
        baseElevation = scene.cameraState.elevation
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

struct MetalMapView: NSViewControllerRepresentable {
    var scene: MapScene

    func makeNSViewController(context: Context) -> MetalMapViewController {
        guard let backend = scene.renderBackend as? MetalRenderBackend else {
            preconditionFailure("scene.renderBackend must be a MetalRenderBackend.")
        }
        return MetalMapViewController(scene: scene, backend: backend)
    }

    func updateNSViewController(_ viewController: MetalMapViewController, context: Context) {
        viewController.update(scene: scene)
    }
}

final class MetalMapViewController: NSViewController, MTKViewDelegate {
    private weak var scene: MapScene?
    private let backend: MetalRenderBackend
    private let commandQueue: any MTLCommandQueue
    private let renderer: MetalMapRenderer
    private var mtkView: MTKView!

    private var baseAzimuth: Float = 0
    private var baseElevation: Float = 0
    private var baseDistance: Float = 0

    init(scene: MapScene, backend: MetalRenderBackend) {
        self.scene = scene
        self.backend = backend
        self.renderer = backend.renderer
        guard let commandQueue = renderer.device.makeCommandQueue() else {
            fatalError("MetalMapViewController: failed to create Metal command queue")
        }
        self.commandQueue = commandQueue
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mtkView = MTKView(frame: view.bounds, device: renderer.device)
        mtkView.autoresizingMask = [.width, .height]
        mtkView.delegate = self
        mtkView.colorPixelFormat = renderer.colorPixelFormat
        mtkView.depthStencilPixelFormat = renderer.depthStencilPixelFormat
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        view.addSubview(mtkView)

        let panGestureRecognizer = NSPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        mtkView.addGestureRecognizer(panGestureRecognizer)

        let magnificationGestureRecognizer = NSMagnificationGestureRecognizer(target: self, action: #selector(handleMagnification(_:)))
        mtkView.addGestureRecognizer(magnificationGestureRecognizer)
    }

    func update(scene: MapScene) {
        self.scene = scene
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }

    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor else {
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

    override func mouseDown(with event: NSEvent) {
        var point = mtkView.convert(event.locationInWindow, from: nil)
        // NSView has bottom-left origin; flip to top-left for hit testing.
        point.y = mtkView.bounds.height - point.y
        if let result = backend.hitTest(point) {
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
