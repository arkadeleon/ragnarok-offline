//
//  RealityVirtualMapView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/8/7.
//

import Combine
import RealityKit
import SwiftUI

#if os(iOS)

struct RealityVirtualMapView: UIViewControllerRepresentable {
    var scene: MapScene
    var backend: RealityRenderBackend

    func makeUIViewController(context: Context) -> RealityVirtualMapViewController {
        RealityVirtualMapViewController(scene: scene, backend: backend)
    }

    func updateUIViewController(_ viewController: RealityVirtualMapViewController, context: Context) {
    }
}

class RealityVirtualMapViewController: UIViewController {
    let scene: MapScene
    let backend: RealityRenderBackend

    private var arView: ARView!
    private var baseAzimuth: Float = 0
    private var baseElevation: Float = 0
    private var baseDistance: Float = 0
    private var sceneSubscription: (any Cancellable)?

    init(scene: MapScene, backend: RealityRenderBackend) {
        self.scene = scene
        self.backend = backend
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        arView = ARView(frame: view.bounds, cameraMode: .nonAR, automaticallyConfigureSession: false)
        arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        arView.environment.background = .color(.black)
        view.addSubview(arView)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tapGestureRecognizer)

        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        arView.addGestureRecognizer(doubleTapGestureRecognizer)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        arView.addGestureRecognizer(panGestureRecognizer)

        let twoFingerPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleTwoFingerPan(_:)))
        twoFingerPanGestureRecognizer.minimumNumberOfTouches = 2
        arView.addGestureRecognizer(twoFingerPanGestureRecognizer)

        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        arView.addGestureRecognizer(pinchGestureRecognizer)

        backend.configure(arView: arView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sceneSubscription = arView.scene.subscribe(to: SceneEvents.Update.self) { [weak self] _ in
            if let self {
                backend.syncAndProjectOverlay()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneSubscription = nil
    }

    @objc func handleTap(_ tapGestureRecognizer: UITapGestureRecognizer) {
        let screenPoint = tapGestureRecognizer.location(in: arView)
        if let result = backend.hitTest(screenPoint) {
            scene.handleInteraction(result)
        }
    }

    @objc func handleDoubleTap(_ tapGestureRecognizer: UITapGestureRecognizer) {
        scene.resetCamera()
        baseAzimuth = scene.cameraState.azimuth
        baseElevation = scene.cameraState.elevation
    }

    @objc func handlePan(_ panGestureRecognizer: UIPanGestureRecognizer) {
        switch panGestureRecognizer.state {
        case .began:
            baseAzimuth = scene.cameraState.azimuth
        case .changed:
            let azimuth = baseAzimuth + Float(panGestureRecognizer.translation(in: arView).x) * 0.01
            scene.cameraState.azimuth = azimuth.truncatingRemainder(dividingBy: .pi * 2)
        default:
            break
        }
    }

    @objc func handleTwoFingerPan(_ panGestureRecognizer: UIPanGestureRecognizer) {
        switch panGestureRecognizer.state {
        case .began:
            baseElevation = scene.cameraState.elevation
        case .changed:
            var elevation = baseElevation + Float(panGestureRecognizer.translation(in: arView).y) * 0.01
            elevation = max(elevation, .pi / 12)
            elevation = min(elevation, .pi / 3)
            scene.cameraState.elevation = elevation
        default:
            break
        }
    }

    @objc func handlePinch(_ pinchGestureRecognizer: UIPinchGestureRecognizer) {
        switch pinchGestureRecognizer.state {
        case .began:
            baseDistance = scene.cameraState.distance
        case .changed:
            var distance = baseDistance * Float(1 / pinchGestureRecognizer.scale)
            distance = max(distance, 3)
            distance = min(distance, 120)
            scene.cameraState.distance = distance
        default:
            break
        }
    }
}

#elseif os(macOS)

struct RealityVirtualMapView: NSViewControllerRepresentable {
    var scene: MapScene
    var backend: RealityRenderBackend

    func makeNSViewController(context: Context) -> RealityVirtualMapViewController {
        RealityVirtualMapViewController(scene: scene, backend: backend)
    }

    func updateNSViewController(_ viewController: RealityVirtualMapViewController, context: Context) {
    }
}

class RealityVirtualMapViewController: NSViewController {
    let scene: MapScene
    let backend: RealityRenderBackend

    private var arView: ARView!
    private var baseAzimuth: Float = 0
    private var baseElevation: Float = 0
    private var baseDistance: Float = 0
    private var sceneSubscription: (any Cancellable)?

    init(scene: MapScene, backend: RealityRenderBackend) {
        self.scene = scene
        self.backend = backend
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        arView = ARView(frame: view.bounds)
        arView.autoresizingMask = [.width, .height]
        arView.environment.background = .color(.black)
        view.addSubview(arView)

        let panGestureRecognizer = NSPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        arView.addGestureRecognizer(panGestureRecognizer)

        let magnificationGestureRecognizer = NSMagnificationGestureRecognizer(target: self, action: #selector(handleMagnification(_:)))
        arView.addGestureRecognizer(magnificationGestureRecognizer)

        backend.configure(arView: arView)
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        sceneSubscription = arView.scene.subscribe(to: SceneEvents.Update.self) { [weak self] _ in
            if let self {
                backend.syncAndProjectOverlay()
            }
        }
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        sceneSubscription = nil
    }

    override func mouseDown(with event: NSEvent) {
        let screenPoint = arView.convert(event.locationInWindow, from: nil)
        if let result = backend.hitTest(screenPoint) {
            scene.handleInteraction(result)
        }
    }

    @objc func handlePan(_ panGestureRecognizer: NSPanGestureRecognizer) {
        switch panGestureRecognizer.state {
        case .began:
            baseAzimuth = scene.cameraState.azimuth
            baseElevation = scene.cameraState.elevation
        case .changed:
            let azimuth = baseAzimuth + Float(panGestureRecognizer.translation(in: arView).x) * 0.01
            scene.cameraState.azimuth = azimuth.truncatingRemainder(dividingBy: .pi * 2)

            var elevation = baseElevation - Float(panGestureRecognizer.translation(in: arView).y) * 0.01
            elevation = max(elevation, .pi / 12)
            elevation = min(elevation, .pi / 3)
            scene.cameraState.elevation = elevation
        default:
            break
        }
    }

    @objc func handleMagnification(_ magnificationGestureRecognizer: NSMagnificationGestureRecognizer) {
        switch magnificationGestureRecognizer.state {
        case .began:
            baseDistance = scene.cameraState.distance
        case .changed:
            var scale = 1 + magnificationGestureRecognizer.magnification
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
