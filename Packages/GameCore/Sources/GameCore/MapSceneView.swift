//
//  MapSceneView.swift
//  GameView
//
//  Created by Leon Li on 2025/8/7.
//

import RealityKit
import SwiftUI

public struct MapSceneView: View {
    public var scene: MapScene

    @State private var distance: Float = 80

    public var body: some View {
        #if os(iOS) || os(macOS)
        MapSceneARView(scene: scene)
            .ignoresSafeArea()
        #else
        RealityView { content in
            content.add(scene.rootEntity)
        } update: { content in
        } placeholder: {
            ProgressView()
        }
        .ignoresSafeArea()
        .gesture(scene.tileTapGesture)
        .gesture(scene.mapObjectTapGesture)
        .gesture(scene.mapItemTapGesture)
        .gesture(
            MagnifyGesture()
                .onChanged { value in
                    var distance = distance * Float(1 / value.magnification)
                    distance = max(distance, 3)
                    distance = min(distance, 100)
                    scene.distance = distance
                }
                .onEnded { value in
                    distance = scene.distance
                }
        )
        #endif
    }

    public init(scene: MapScene) {
        self.scene = scene
    }
}

#if os(iOS)

struct MapSceneARView: UIViewControllerRepresentable {
    var scene: MapScene

    func makeUIViewController(context: Context) -> MapSceneARViewController {
        MapSceneARViewController(scene: scene)
    }

    func updateUIViewController(_ viewController: MapSceneARViewController, context: Context) {
    }
}

class MapSceneARViewController: UIViewController {
    let scene: MapScene

    private var arView: ARView!
    private var distance: Float = 80

    init(scene: MapScene) {
        self.scene = scene
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

        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        arView.addGestureRecognizer(pinchGestureRecognizer)
    }

    @objc func handleTap(_ tapGestureRecognizer: UITapGestureRecognizer) {
        let screenPoint = tapGestureRecognizer.location(in: arView)

        if let entity = arView.entity(at: screenPoint) {
            scene.hitEntity(entity)
        } else if let (origin, direction) = arView.ray(through: screenPoint) {
            scene.raycast(origin: origin, direction: direction)
        }
    }

    @objc func handlePinch(_ pinchGestureRecognizer: UIPinchGestureRecognizer) {
        switch pinchGestureRecognizer.state {
        case .began:
            distance = scene.distance
        case .changed:
            var distance = distance * Float(1 / pinchGestureRecognizer.scale)
            distance = max(distance, 3)
            distance = min(distance, 100)
            scene.distance = distance
        default:
            break
        }
    }
}

#elseif os(macOS)

struct MapSceneARView: NSViewControllerRepresentable {
    var scene: MapScene

    func makeNSViewController(context: Context) -> MapSceneARViewController {
        MapSceneARViewController(scene: scene)
    }

    func updateNSViewController(_ viewController: MapSceneARViewController, context: Context) {
    }
}

class MapSceneARViewController: NSViewController {
    let scene: MapScene

    private var arView: ARView!

    init(scene: MapScene) {
        self.scene = scene
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
    }

    override func mouseDown(with event: NSEvent) {
        let screenPoint = arView.convert(event.locationInWindow, from: nil)
        if let entity = arView.entity(at: screenPoint) {
            scene.hitEntity(entity)
        } else if let (origin, direction) = arView.ray(through: screenPoint) {
            scene.raycast(origin: origin, direction: direction)
        }
    }

    override func scrollWheel(with event: NSEvent) {
        // handle magnification
    }
}

#endif
