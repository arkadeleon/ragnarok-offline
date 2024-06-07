//
//  ModelViewer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/16.
//

import RealityKit
import SwiftUI

struct ModelViewer: UIViewControllerRepresentable {
    var model: Entity

    func makeUIViewController(context: Context) -> ModelViewerController {
        ModelViewerController(model: model)
    }

    func updateUIViewController(_ modelViewerController: ModelViewerController, context: Context) {
    }
}

class ModelViewerController: UIViewController {
    let model: Entity

    private var startScale: SIMD3<Float> = .one

    private var pivotEntity: Entity?
    private var startOrientation = simd_quatf()

    init(model: Entity) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let arView = ARView(frame: view.bounds, cameraMode: .nonAR, automaticallyConfigureSession: false)
        arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        arView.environment.background = .color(.systemBackground)
        view.addSubview(arView)

        let cameraEntity = PerspectiveCamera()
        cameraEntity.name = "Camera"
        cameraEntity.look(at: .zero, from: [0, 0, 2.5], relativeTo: nil)

        let lightEntity = DirectionalLight()
        lightEntity.name = "Light"
        lightEntity.light.color = .white
        lightEntity.light.intensity = 2000
        lightEntity.look(at: .zero, from: [0, 0, 2], relativeTo: nil)

        let worldAnchor = AnchorEntity(world: .zero)
        worldAnchor.addChild(model)
        worldAnchor.addChild(cameraEntity)
        worldAnchor.addChild(lightEntity)
        arView.scene.addAnchor(worldAnchor)

        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        arView.addGestureRecognizer(pinchGestureRecognizer)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        arView.addGestureRecognizer(panGestureRecognizer)
    }

    @objc func handlePinch(_ pinchGestureRecognizer: UIPinchGestureRecognizer) {
        switch pinchGestureRecognizer.state {
        case .began:
            startScale = model.scale
        case .changed:
            let scale = startScale * Float(pinchGestureRecognizer.scale)
            model.scale = scale
        default:
            break
        }
    }

    @objc func handlePan(_ panGestureRecognizer: UIPanGestureRecognizer) {
        switch panGestureRecognizer.state {
        case .began:
            let position = model.position

            let pivotEntity = Entity()
            model.parent?.addChild(pivotEntity)
            pivotEntity.position = position
            pivotEntity.addChild(model, preservingWorldTransform: true)
            self.pivotEntity = pivotEntity

            startOrientation = pivotEntity.orientation
        case .changed:
            let translation = panGestureRecognizer.translation(in: view)

            let yScalar = Float(translation.x / view.bounds.size.width)
            let yRadians = yScalar * .pi * 2

            // Use the pan translation along the y axis to adjust the camera's rotation about the x axis (up and down navigation).
            let xScalar = Float(translation.y / view.bounds.size.height)
            let xRadians = xScalar * .pi * 2

            var orientation = startOrientation

            // Perform up and down rotations around *CAMERA* X axis (note the order of multiplication)
            let xMultiplier = simd_quatf(angle: xRadians, axis: [1, 0, 0])
            orientation = orientation * xMultiplier

            // Perform side to side rotations around *WORLD* Y axis (note the order of multiplication, different from above)
            let yMultiplier = simd_quatf(angle: yRadians, axis: [0, 1, 0])
            orientation = orientation * yMultiplier

            pivotEntity?.orientation = orientation
        case .ended:
            pivotEntity?.parent?.addChild(model, preservingWorldTransform: true)
            pivotEntity?.removeFromParent()
            pivotEntity = nil
        default:
            break
        }
    }
}

#Preview {
    ModelViewer(model: Entity())
}
