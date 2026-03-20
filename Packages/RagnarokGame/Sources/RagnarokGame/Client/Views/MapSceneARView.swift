//
//  MapSceneARView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/8/7.
//

import Combine
import RealityKit
import SwiftUI

#if os(iOS)

struct MapSceneARView: UIViewControllerRepresentable {
    var scene: MapScene
    var onSceneUpdate: (ARView) -> Void

    func makeUIViewController(context: Context) -> MapSceneARViewController {
        MapSceneARViewController(scene: scene, onSceneUpdate: onSceneUpdate)
    }

    func updateUIViewController(_ viewController: MapSceneARViewController, context: Context) {
    }
}

class MapSceneARViewController: UIViewController {
    let scene: MapScene
    let onSceneUpdate: (ARView) -> Void

    private var arView: ARView!
    private var baseAzimuth: Float = 0
    private var baseElevation: Float = 0
    private var baseDistance: Float = 0
    private var sceneSubscription: (any Cancellable)?

    init(scene: MapScene, onSceneUpdate: @escaping (ARView) -> Void) {
        self.scene = scene
        self.onSceneUpdate = onSceneUpdate
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

        let anchorEntity = AnchorEntity(world: .zero)
        anchorEntity.addChild(scene.rootEntity)
        arView.scene.addAnchor(anchorEntity)

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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sceneSubscription = arView.scene.subscribe(to: SceneEvents.Update.self) { [weak self] _ in
            if let self {
                onSceneUpdate(arView)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneSubscription = nil
    }

    @objc func handleTap(_ tapGestureRecognizer: UITapGestureRecognizer) {
        let screenPoint = tapGestureRecognizer.location(in: arView)

        if let (origin, direction) = arView.ray(through: screenPoint) {
            scene.raycast(origin: origin, direction: direction, in: arView.scene)
        }
    }

    @objc func handleDoubleTap(_ tapGestureRecognizer: UITapGestureRecognizer) {
        scene.cameraState.azimuth = 0
        scene.cameraState.elevation = .pi / 4
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

struct MapSceneARView: NSViewControllerRepresentable {
    var scene: MapScene
    var onSceneUpdate: (ARView) -> Void

    func makeNSViewController(context: Context) -> MapSceneARViewController {
        MapSceneARViewController(scene: scene, onSceneUpdate: onSceneUpdate)
    }

    func updateNSViewController(_ viewController: MapSceneARViewController, context: Context) {
    }
}

class MapSceneARViewController: NSViewController {
    let scene: MapScene
    let onSceneUpdate: (ARView) -> Void

    private var arView: ARView!
    private var baseAzimuth: Float = 0
    private var baseElevation: Float = 0
    private var baseDistance: Float = 0
    private var sceneSubscription: (any Cancellable)?

    init(scene: MapScene, onSceneUpdate: @escaping (ARView) -> Void) {
        self.scene = scene
        self.onSceneUpdate = onSceneUpdate
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

        let anchorEntity = AnchorEntity(world: .zero)
        anchorEntity.addChild(scene.rootEntity)
        arView.scene.addAnchor(anchorEntity)

        let panGestureRecognizer = NSPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        arView.addGestureRecognizer(panGestureRecognizer)

        let magnificationGestureRecognizer = NSMagnificationGestureRecognizer(target: self, action: #selector(handleMagnification(_:)))
        arView.addGestureRecognizer(magnificationGestureRecognizer)
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        sceneSubscription = arView.scene.subscribe(to: SceneEvents.Update.self) { [weak self] _ in
            if let self {
                onSceneUpdate(arView)
            }
        }
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        sceneSubscription = nil
    }

    override func mouseDown(with event: NSEvent) {
        let screenPoint = arView.convert(event.locationInWindow, from: nil)
        if let (origin, direction) = arView.ray(through: screenPoint) {
            scene.raycast(origin: origin, direction: direction, in: arView.scene)
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
