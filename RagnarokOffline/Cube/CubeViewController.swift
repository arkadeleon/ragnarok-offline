//
//  CubeViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/14.
//

import RealityKit
import UIKit

class CubeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let arView = ARView(frame: view.bounds, cameraMode: .nonAR, automaticallyConfigureSession: false)
        arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        arView.environment.background = .color(.systemBackground)
        view.addSubview(arView)

        let texture = try! MaterialParameters.Texture(.load(named: "wall.jpg"))
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(texture: texture)

        let boxEntity = ModelEntity(mesh: .generateBox(size: 1), materials: [material])

        let boxAnchor = AnchorEntity(world: .zero)
        boxAnchor.addChild(boxEntity)
        arView.scene.addAnchor(boxAnchor)

        let cameraEntity = PerspectiveCamera()
        cameraEntity.camera.fieldOfViewInDegrees = 60
        cameraEntity.look(at: .zero, from: [0, 3, 0], relativeTo: nil)

        let cameraAnchor = AnchorEntity(world: .zero)
        cameraAnchor.addChild(cameraEntity)
        arView.scene.addAnchor(cameraAnchor)

        boxEntity.generateCollisionShapes(recursive: false)
        arView.installGestures([.all], for: boxEntity)
    }
}
