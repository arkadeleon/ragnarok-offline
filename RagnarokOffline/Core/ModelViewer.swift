//
//  ModelViewer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/16.
//

import RealityKit
import SwiftUI

#if os(iOS) || os(macOS)

struct ModelViewer: View {
    var entity: Entity

    var body: some View {
//        RealityModelViewer(entity: entity)
        ARModelViewer(entity: entity)
    }
}

struct RealityModelViewer: View {
    var entity: Entity

    @State private var cameraControls: CameraControls = .tilt

    private var cameraControlsPlacement: ToolbarItemPlacement {
        #if os(iOS)
        .bottomBar
        #else
        .automatic
        #endif
    }

    var body: some View {
        RealityView { content in
            content.camera = .virtual
            content.add(entity)
        } placeholder: {
            ProgressView()
        }
        .realityViewCameraControls(cameraControls)
        .toolbar {
            ToolbarItem(placement: cameraControlsPlacement) {
                Picker(selection: $cameraControls) {
                    Image(systemName: "dot.arrowtriangles.up.right.down.left.circle")
                        .tag(CameraControls.tilt)
                    Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                        .tag(CameraControls.pan)
                    Image(systemName: "rotate.3d")
                        .tag(CameraControls.orbit)
                    Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
                        .tag(CameraControls.dolly)
                } label: {
                    Image(systemName: "video")
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

#endif

#if os(iOS)

struct ARModelViewer: UIViewControllerRepresentable {
    var entity: Entity

    func makeUIViewController(context: Context) -> ARModelViewerController {
        ARModelViewerController(entity: entity)
    }

    func updateUIViewController(_ modelViewerController: ARModelViewerController, context: Context) {
    }
}

class ARModelViewerController: UIViewController {
    let entity: Entity

    private var startScale: SIMD3<Float> = .one

    private var pivotEntity: Entity?
    private var startOrientation = simd_quatf()

    init(entity: Entity) {
        self.entity = entity
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
        cameraEntity.look(at: .zero, from: [0, 0, 2.5], relativeTo: nil)

        let lightEntity = DirectionalLight()
        lightEntity.light.color = .white
        lightEntity.light.intensity = 3000
        lightEntity.look(at: .zero, from: [0, 0, 2.5], relativeTo: nil)

        let worldAnchor = AnchorEntity(world: .zero)
        worldAnchor.addChild(entity)
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
            startScale = entity.scale
        case .changed:
            let scale = startScale * Float(pinchGestureRecognizer.scale)
            entity.scale = scale
        default:
            break
        }
    }

    @objc func handlePan(_ panGestureRecognizer: UIPanGestureRecognizer) {
        switch panGestureRecognizer.state {
        case .began:
            let position = entity.position

            let pivotEntity = Entity()
            entity.parent?.addChild(pivotEntity)
            pivotEntity.position = position
            pivotEntity.addChild(entity, preservingWorldTransform: true)
            self.pivotEntity = pivotEntity

            startOrientation = pivotEntity.orientation
        case .changed:
            let translation = panGestureRecognizer.translation(in: view)

            let yScalar = Float(translation.x / 1024)
            let yRadians = yScalar * .pi * 2

            // Use the pan translation along the y axis to adjust the camera's rotation about the x axis (up and down navigation).
            let xScalar = Float(translation.y / 1024)
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
            pivotEntity?.parent?.addChild(entity, preservingWorldTransform: true)
            pivotEntity?.removeFromParent()
            pivotEntity = nil
        default:
            break
        }
    }
}

#endif

#if os(macOS)

struct ARModelViewer: NSViewControllerRepresentable {
    var entity: Entity

    func makeNSViewController(context: Context) -> ARModelViewerController {
        ARModelViewerController(entity: entity)
    }

    func updateNSViewController(_ modelViewerController: ARModelViewerController, context: Context) {
    }
}

class ARModelViewerController: NSViewController {
    let entity: Entity

    private var startScale: SIMD3<Float> = .one

    private var pivotEntity: Entity?
    private var startOrientation = simd_quatf()

    init(entity: Entity) {
        self.entity = entity
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let arView = ARView(frame: view.bounds)
        arView.autoresizingMask = [.width, .height]
        arView.environment.background = .color(.windowBackgroundColor)
        view.addSubview(arView)

        let cameraEntity = PerspectiveCamera()
        cameraEntity.look(at: .zero, from: [0, 0, 2.5], relativeTo: nil)

        let lightEntity = DirectionalLight()
        lightEntity.light.color = .white
        lightEntity.light.intensity = 3000
        lightEntity.look(at: .zero, from: [0, 0, 2.5], relativeTo: nil)

        let worldAnchor = AnchorEntity(world: .zero)
        worldAnchor.addChild(entity)
        worldAnchor.addChild(cameraEntity)
        worldAnchor.addChild(lightEntity)
        arView.scene.addAnchor(worldAnchor)

        let magnificationGestureRecognizer = NSMagnificationGestureRecognizer(target: self, action: #selector(handleMagnification(_:)))
        arView.addGestureRecognizer(magnificationGestureRecognizer)

        let panGestureRecognizer = NSPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        arView.addGestureRecognizer(panGestureRecognizer)
    }

    @objc func handleMagnification(_ magnificationGestureRecognizer: NSMagnificationGestureRecognizer) {
        switch magnificationGestureRecognizer.state {
        case .began:
            startScale = entity.scale
        case .changed:
            let scale = startScale * Float(magnificationGestureRecognizer.magnification)
            entity.scale = scale
        default:
            break
        }
    }

    @objc func handlePan(_ panGestureRecognizer: NSPanGestureRecognizer) {
        switch panGestureRecognizer.state {
        case .began:
            let position = entity.position

            let pivotEntity = Entity()
            entity.parent?.addChild(pivotEntity)
            pivotEntity.position = position
            pivotEntity.addChild(entity, preservingWorldTransform: true)
            self.pivotEntity = pivotEntity

            startOrientation = pivotEntity.orientation
        case .changed:
            let translation = panGestureRecognizer.translation(in: view)

            let yScalar = Float(translation.x / 1024)
            let yRadians = yScalar * .pi * 2

            // Use the pan translation along the y axis to adjust the camera's rotation about the x axis (up and down navigation).
            let xScalar = Float(translation.y / 1024)
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
            pivotEntity?.parent?.addChild(entity, preservingWorldTransform: true)
            pivotEntity?.removeFromParent()
            pivotEntity = nil
        default:
            break
        }
    }
}

#endif

#if os(visionOS)

struct ModelViewer: View {
    var entity: Entity

    var body: some View {
        RealityView { content in
            content.add(entity)
        }
    }
}

#endif

#Preview {
    ModelViewer(entity: Entity())
}
