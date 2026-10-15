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
    var isWidescreen: Bool

    func makeUIViewController(context: Context) -> MapViewController {
        let viewController = MapViewController(runtime: runtime)
        viewController.isWidescreen = isWidescreen
        return viewController
    }

    func updateUIViewController(_ viewController: MapViewController, context: Context) {
        viewController.update(runtime: runtime)
        viewController.isWidescreen = isWidescreen
    }
}

final class MapViewController: UIViewController, MTKViewDelegate, UIGestureRecognizerDelegate {
    private weak var runtime: MapSceneRuntime?
    private let commandQueue: any MTLCommandQueue
    private let renderer: MapSceneRenderer
    private var mtkView: MTKView!

    /// The thumbstick uses the left half of the map on a wide screen, and the bottom half otherwise.
    /// The camera uses the other half.
    var isWidescreen = true

    #if os(iOS)
    private let thumbstickView = ThumbstickView()
    private let thumbstickFeedbackGenerator = UISelectionFeedbackGenerator()
    private var thumbstickOctant: Int?
    private var thumbstickPanGestureRecognizer: UIPanGestureRecognizer!
    #endif

    private var cameraPanGestureRecognizer: UIPanGestureRecognizer!
    private var twoFingerGestureRecognizers: [UIGestureRecognizer] = []

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

        #if os(iOS)
        view.addSubview(thumbstickView)
        #endif

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGestureRecognizer.delegate = self
        mtkView.addGestureRecognizer(tapGestureRecognizer)

        #if os(iOS)
        thumbstickPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleThumbstickPan(_:)))
        thumbstickPanGestureRecognizer.maximumNumberOfTouches = 1
        thumbstickPanGestureRecognizer.delegate = self
        mtkView.addGestureRecognizer(thumbstickPanGestureRecognizer)
        #endif

        cameraPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleCameraPan(_:)))
        cameraPanGestureRecognizer.delegate = self
        mtkView.addGestureRecognizer(cameraPanGestureRecognizer)

        let twoFingerTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTwoFingerTap(_:)))
        twoFingerTapGestureRecognizer.numberOfTouchesRequired = 2
        twoFingerTapGestureRecognizer.delegate = self
        mtkView.addGestureRecognizer(twoFingerTapGestureRecognizer)

        let twoFingerPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleTwoFingerPan(_:)))
        twoFingerPanGestureRecognizer.minimumNumberOfTouches = 2
        twoFingerPanGestureRecognizer.delegate = self
        mtkView.addGestureRecognizer(twoFingerPanGestureRecognizer)

        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinchGestureRecognizer.delegate = self
        mtkView.addGestureRecognizer(pinchGestureRecognizer)

        twoFingerGestureRecognizers = [twoFingerTapGestureRecognizer, twoFingerPanGestureRecognizer, pinchGestureRecognizer]
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

    #if os(iOS)
    @objc func handleThumbstickPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: mtkView)

        switch gestureRecognizer.state {
        case .began, .changed:
            if gestureRecognizer.state == .began {
                let location = gestureRecognizer.location(in: mtkView)
                let radius = ThumbstickView.radius
                let bounds = mtkView.bounds
                let touchDownPoint = CGPoint(
                    x: min(max(location.x - translation.x, bounds.minX + radius), bounds.maxX - radius),
                    y: min(max(location.y - translation.y, bounds.minY + radius), bounds.maxY - radius)
                )
                thumbstickView.show(at: touchDownPoint)
                thumbstickFeedbackGenerator.prepare()
            }

            let distance = hypot(translation.x, translation.y)
            let scale = min(ThumbstickView.knobTravel / max(distance, .leastNonzeroMagnitude), 1)
            let offset = CGPoint(x: translation.x * scale, y: translation.y * scale)
            runtime?.scene.thumbstickValue = offset

            let octant = runtime?.scene.thumbstickOctant
            if let octant, octant != thumbstickOctant {
                thumbstickFeedbackGenerator.selectionChanged()
            }
            thumbstickOctant = octant

            guard let octant else {
                thumbstickView.moveKnob(by: offset)
                break
            }

            let snapAngle: CGFloat = .pi / 18
            let boundaryAngle: CGFloat = .pi / 8
            let azimuth = CGFloat(runtime?.scene.camera.azimuth ?? 0)
            let octantAngle = CGFloat(octant) * .pi / 4 + azimuth
            let angleFromOctant = remainder(atan2(-offset.y, offset.x) - octantAngle, .pi * 2)
            let knobAngleFromOctant = min(max(abs(angleFromOctant) - snapAngle, 0) / (boundaryAngle - snapAngle) * boundaryAngle, abs(angleFromOctant))
            let knobAngle = octantAngle + (angleFromOctant < 0 ? -knobAngleFromOctant : knobAngleFromOctant)
            let knobDistance = hypot(offset.x, offset.y)
            thumbstickView.moveKnob(by: CGPoint(x: cos(knobAngle) * knobDistance, y: -sin(knobAngle) * knobDistance))
        default:
            thumbstickView.isHidden = true
            thumbstickOctant = nil
            runtime?.scene.thumbstickValue = .zero
        }
    }
    #endif

    @objc func handleCameraPan(_ gestureRecognizer: UIPanGestureRecognizer) {
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

    @objc func handleTwoFingerTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let scene = runtime?.scene else {
            return
        }

        scene.resetCamera()
        baseAzimuth = scene.camera.azimuth
        baseElevation = scene.camera.elevation
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

    // MARK: - UIGestureRecognizerDelegate

    #if os(iOS)
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // Two fingers on the map mean the player is zooming or tilting the camera, not moving.
        if gestureRecognizer === thumbstickPanGestureRecognizer {
            return twoFingerGestureRecognizers.allSatisfy { $0.numberOfTouches < 2 }
        }

        guard twoFingerGestureRecognizers.contains(where: { $0 === gestureRecognizer }) else {
            return true
        }

        // Don't zoom or tilt the camera with a finger that is moving the player.
        let thumbstickState = thumbstickPanGestureRecognizer.state
        return thumbstickState != .began && thumbstickState != .changed
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let isThumbstickInvolved = gestureRecognizer === thumbstickPanGestureRecognizer || otherGestureRecognizer === thumbstickPanGestureRecognizer
        let isTwoFingerInvolved = twoFingerGestureRecognizers.contains { $0 === gestureRecognizer || $0 === otherGestureRecognizer }
        return isThumbstickInvolved && !isTwoFingerInvolved
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: mtkView)
        let isOnThumbstickHalf = isWidescreen ? location.x < mtkView.bounds.midX : location.y >= mtkView.bounds.midY
        if gestureRecognizer === thumbstickPanGestureRecognizer {
            return isOnThumbstickHalf
        } else if gestureRecognizer === cameraPanGestureRecognizer {
            return !isOnThumbstickHalf
        } else {
            return true
        }
    }
    #endif
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
