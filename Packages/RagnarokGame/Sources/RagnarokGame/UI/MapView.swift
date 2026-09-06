//
//  MapView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/22.
//

import MetalKit
import RagnarokRendering
import SwiftUI

#if canImport(UIKit)

struct MapView: UIViewControllerRepresentable {
    var runtime: MapSceneRuntime

    func makeUIViewController(context: Context) -> MapViewController {
        MapViewController(runtime: runtime)
    }

    func updateUIViewController(_ viewController: MapViewController, context: Context) {
        viewController.update(runtime: runtime)
    }
}

final class MapViewController: UIViewController, MTKViewDelegate {
    private weak var runtime: MapSceneRuntime?
    private let commandQueue: any MTLCommandQueue
    private let renderer: MapSceneRenderer
    private var mtkView: MTKView!

    private var baseAzimuth: Float = 0
    private var baseElevation: Float = 0
    private var baseDistance: Float = 0

    init(runtime: MapSceneRuntime) {
        self.runtime = runtime

        let device = runtime.renderResources.device

        do {
            self.renderer = try MapSceneRenderer(device: device, configuration: .default)
        } catch {
            fatalError("MapViewController: failed to create map scene renderer: \(error)")
        }

        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("MapViewController: failed to create Metal command queue")
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
        mtkView.isOpaque = true
        mtkView.delegate = self
        mtkView.colorPixelFormat = renderer.configuration.colorPixelFormat
        mtkView.depthStencilPixelFormat = renderer.configuration.depthStencilPixelFormat
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
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

    func update(runtime: MapSceneRuntime) {
        self.runtime = runtime
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }

    func draw(in view: MTKView) {
        guard let runtime,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor else {
            return
        }

        let now = ContinuousClock.now
        let currentTime = CACurrentMediaTime()

        runtime.update(at: now, renderTime: currentTime)
        let snapshot = runtime.makeRenderSnapshot(at: now)

        let viewport = MTLViewport(size: view.drawableSize)
        let camera = runtime.makeCamera(viewport: viewport)
        runtime.lastCamera = camera

        let frame = RenderFrame(
            time: currentTime,
            commandBuffer: commandBuffer,
            renderPassDescriptor: renderPassDescriptor,
            views: [
                RenderView(viewport: viewport, camera: camera)
            ],
            bounds: view.bounds
        )
        renderer.render(frame: frame, snapshot: snapshot)

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let runtime else {
            return
        }

        let point = gestureRecognizer.location(in: mtkView)
        guard let camera = runtime.lastCamera,
              let ray = camera.ray(through: point, in: mtkView.bounds) else {
            return
        }
        if let result = runtime.hitTest(ray) {
            runtime.scene.handleInteraction(result)
        }
    }

    @objc func handleTwoFingerTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let scene = runtime?.scene else {
            return
        }

        scene.resetCamera()
        baseAzimuth = scene.camera.azimuth
        baseElevation = scene.camera.elevation
    }

    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let scene = runtime?.scene else {
            return
        }

        switch gestureRecognizer.state {
        case .began:
            baseAzimuth = scene.camera.azimuth
        case .changed:
            let azimuth = baseAzimuth + Float(gestureRecognizer.translation(in: mtkView).x) * 0.01
            scene.camera.azimuth = azimuth.truncatingRemainder(dividingBy: .pi * 2)
        default:
            break
        }
    }

    @objc func handleTwoFingerPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let scene = runtime?.scene else {
            return
        }

        switch gestureRecognizer.state {
        case .began:
            baseElevation = scene.camera.elevation
        case .changed:
            var elevation = baseElevation + Float(gestureRecognizer.translation(in: mtkView).y) * 0.01
            elevation = max(elevation, .pi / 12)
            elevation = min(elevation, .pi / 3)
            scene.camera.elevation = elevation
        default:
            break
        }
    }

    @objc func handlePinch(_ gestureRecognizer: UIPinchGestureRecognizer) {
        guard let scene = runtime?.scene else {
            return
        }

        switch gestureRecognizer.state {
        case .began:
            baseDistance = scene.camera.distance
        case .changed:
            var distance = baseDistance * Float(1 / gestureRecognizer.scale)
            distance = max(distance, 3)
            distance = min(distance, 120)
            scene.camera.distance = distance
        default:
            break
        }
    }
}

#elseif canImport(AppKit)

struct MapView: NSViewControllerRepresentable {
    var runtime: MapSceneRuntime

    func makeNSViewController(context: Context) -> MapViewController {
        MapViewController(runtime: runtime)
    }

    func updateNSViewController(_ viewController: MapViewController, context: Context) {
        viewController.update(runtime: runtime)
    }
}

final class MapViewController: NSViewController, MTKViewDelegate {
    private weak var runtime: MapSceneRuntime?
    private let commandQueue: any MTLCommandQueue
    private let renderer: MapSceneRenderer
    private var mtkView: MTKView!

    private var baseAzimuth: Float = 0
    private var baseElevation: Float = 0
    private var baseDistance: Float = 0

    init(runtime: MapSceneRuntime) {
        self.runtime = runtime

        let device = runtime.renderResources.device

        do {
            self.renderer = try MapSceneRenderer(device: device, configuration: .default)
        } catch {
            fatalError("MapViewController: failed to create map scene renderer: \(error)")
        }

        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("MapViewController: failed to create Metal command queue")
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
        mtkView.colorPixelFormat = renderer.configuration.colorPixelFormat
        mtkView.depthStencilPixelFormat = renderer.configuration.depthStencilPixelFormat
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        view.addSubview(mtkView)

        let panGestureRecognizer = NSPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        mtkView.addGestureRecognizer(panGestureRecognizer)

        let magnificationGestureRecognizer = NSMagnificationGestureRecognizer(target: self, action: #selector(handleMagnification(_:)))
        mtkView.addGestureRecognizer(magnificationGestureRecognizer)
    }

    func update(runtime: MapSceneRuntime) {
        self.runtime = runtime
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }

    func draw(in view: MTKView) {
        guard let runtime,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor else {
            return
        }

        let now = ContinuousClock.now
        let currentTime = CACurrentMediaTime()

        runtime.update(at: now, renderTime: currentTime)
        let snapshot = runtime.makeRenderSnapshot(at: now)

        let viewport = MTLViewport(size: view.drawableSize)
        let camera = runtime.makeCamera(viewport: viewport)
        runtime.lastCamera = camera

        let frame = RenderFrame(
            time: currentTime,
            commandBuffer: commandBuffer,
            renderPassDescriptor: renderPassDescriptor,
            views: [
                RenderView(viewport: viewport, camera: camera)
            ],
            bounds: view.bounds
        )
        renderer.render(frame: frame, snapshot: snapshot)

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    override func mouseDown(with event: NSEvent) {
        guard let runtime else {
            return
        }

        var point = mtkView.convert(event.locationInWindow, from: nil)
        // NSView has bottom-left origin; flip to top-left for hit testing.
        point.y = mtkView.bounds.height - point.y
        guard let camera = runtime.lastCamera,
              let ray = camera.ray(through: point, in: mtkView.bounds) else {
            return
        }
        if let result = runtime.hitTest(ray) {
            runtime.scene.handleInteraction(result)
        }
    }

    @objc func handlePan(_ gestureRecognizer: NSPanGestureRecognizer) {
        guard let scene = runtime?.scene else {
            return
        }

        switch gestureRecognizer.state {
        case .began:
            baseAzimuth = scene.camera.azimuth
            baseElevation = scene.camera.elevation
        case .changed:
            let azimuth = baseAzimuth + Float(gestureRecognizer.translation(in: mtkView).x) * 0.01
            scene.camera.azimuth = azimuth.truncatingRemainder(dividingBy: .pi * 2)

            var elevation = baseElevation - Float(gestureRecognizer.translation(in: mtkView).y) * 0.01
            elevation = max(elevation, .pi / 12)
            elevation = min(elevation, .pi / 3)
            scene.camera.elevation = elevation
        default:
            break
        }
    }

    @objc func handleMagnification(_ gestureRecognizer: NSMagnificationGestureRecognizer) {
        guard let scene = runtime?.scene else {
            return
        }

        switch gestureRecognizer.state {
        case .began:
            baseDistance = scene.camera.distance
        case .changed:
            var scale = 1 + gestureRecognizer.magnification
            scale = max(scale, .leastNonzeroMagnitude)

            var distance = baseDistance * Float(1 / scale)
            distance = max(distance, 3)
            distance = min(distance, 120)
            scene.camera.distance = distance
        default:
            break
        }
    }
}

#endif
