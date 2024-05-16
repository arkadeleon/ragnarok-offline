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

        let cubeAnchor = AnchorEntity(world: .zero)

        let texture = try! MaterialParameters.Texture(.load(named: "wall.jpg"))
        var material = SimpleMaterial()
        material.color = .init(texture: texture)

        let cubeEntity = ModelEntity(mesh: generateCube(), materials: [material])
        cubeAnchor.addChild(cubeEntity)

        let lightEntity = DirectionalLight()
        lightEntity.light.color = .white
        lightEntity.light.intensity = 0.2
        lightEntity.look(at: .zero, from: [0, 5, 5], relativeTo: nil)
        cubeAnchor.addChild(lightEntity)

        arView.scene.addAnchor(cubeAnchor)

        let cameraEntity = PerspectiveCamera()
        cameraEntity.camera.fieldOfViewInDegrees = 70
        cameraEntity.look(at: .zero, from: [0, 2.5, 0], relativeTo: nil)

        let cameraAnchor = AnchorEntity(world: .zero)
        cameraAnchor.addChild(cameraEntity)
        arView.scene.addAnchor(cameraAnchor)

        cubeEntity.generateCollisionShapes(recursive: false)
        arView.installGestures([.all], for: cubeEntity)
    }

    private func generateCube() -> MeshResource {
        var descriptor = MeshDescriptor()

        descriptor.positions = MeshBuffer([
            [-0.5, -0.5, -0.5],
            [ 0.5, -0.5, -0.5],
            [ 0.5,  0.5, -0.5],
            [ 0.5,  0.5, -0.5],
            [-0.5,  0.5, -0.5],
            [-0.5, -0.5, -0.5],
            [-0.5, -0.5,  0.5],
            [ 0.5, -0.5,  0.5],
            [ 0.5,  0.5,  0.5],
            [ 0.5,  0.5,  0.5],
            [-0.5,  0.5,  0.5],
            [-0.5, -0.5,  0.5],
            [-0.5,  0.5,  0.5],
            [-0.5,  0.5, -0.5],
            [-0.5, -0.5, -0.5],
            [-0.5, -0.5, -0.5],
            [-0.5, -0.5,  0.5],
            [-0.5,  0.5,  0.5],
            [ 0.5,  0.5,  0.5],
            [ 0.5,  0.5, -0.5],
            [ 0.5, -0.5, -0.5],
            [ 0.5, -0.5, -0.5],
            [ 0.5, -0.5,  0.5],
            [ 0.5,  0.5,  0.5],
            [-0.5, -0.5, -0.5],
            [ 0.5, -0.5, -0.5],
            [ 0.5, -0.5,  0.5],
            [ 0.5, -0.5,  0.5],
            [-0.5, -0.5,  0.5],
            [-0.5, -0.5, -0.5],
            [-0.5,  0.5, -0.5],
            [ 0.5,  0.5, -0.5],
            [ 0.5,  0.5,  0.5],
            [ 0.5,  0.5,  0.5],
            [-0.5,  0.5,  0.5],
            [-0.5,  0.5, -0.5],
        ])

        descriptor.normals = MeshBuffer([
            [0.0,  0.0, -1.0],
            [0.0,  0.0, -1.0],
            [0.0,  0.0, -1.0],
            [0.0,  0.0, -1.0],
            [0.0,  0.0, -1.0],
            [0.0,  0.0, -1.0],
            [0.0,  0.0,  1.0],
            [0.0,  0.0,  1.0],
            [0.0,  0.0,  1.0],
            [0.0,  0.0,  1.0],
            [0.0,  0.0,  1.0],
            [0.0,  0.0,  1.0],
            [1.0,  0.0,  0.0],
            [1.0,  0.0,  0.0],
            [1.0,  0.0,  0.0],
            [1.0,  0.0,  0.0],
            [1.0,  0.0,  0.0],
            [1.0,  0.0,  0.0],
            [1.0,  0.0,  0.0],
            [1.0,  0.0,  0.0],
            [1.0,  0.0,  0.0],
            [1.0,  0.0,  0.0],
            [1.0,  0.0,  0.0],
            [1.0,  0.0,  0.0],
            [0.0, -1.0,  0.0],
            [0.0, -1.0,  0.0],
            [0.0, -1.0,  0.0],
            [0.0, -1.0,  0.0],
            [0.0, -1.0,  0.0],
            [0.0, -1.0,  0.0],
            [0.0,  1.0,  0.0],
            [0.0,  1.0,  0.0],
            [0.0,  1.0,  0.0],
            [0.0,  1.0,  0.0],
            [0.0,  1.0,  0.0],
            [0.0,  1.0,  0.0],
        ])

        descriptor.textureCoordinates = MeshBuffer([
            [0.0, 0.0],
            [1.0, 0.0],
            [1.0, 1.0],
            [1.0, 1.0],
            [0.0, 1.0],
            [0.0, 0.0],
            [0.0, 0.0],
            [1.0, 0.0],
            [1.0, 1.0],
            [1.0, 1.0],
            [0.0, 1.0],
            [0.0, 0.0],
            [1.0, 0.0],
            [1.0, 1.0],
            [0.0, 1.0],
            [0.0, 1.0],
            [0.0, 0.0],
            [1.0, 0.0],
            [1.0, 0.0],
            [1.0, 1.0],
            [0.0, 1.0],
            [0.0, 1.0],
            [0.0, 0.0],
            [1.0, 0.0],
            [0.0, 1.0],
            [1.0, 1.0],
            [1.0, 0.0],
            [1.0, 0.0],
            [0.0, 0.0],
            [0.0, 1.0],
            [0.0, 1.0],
            [1.0, 1.0],
            [1.0, 0.0],
            [1.0, 0.0],
            [0.0, 0.0],
            [0.0, 1.0],
        ])

        let indices = (0..<descriptor.positions.count).map({ UInt32($0) })
        descriptor.primitives = .triangles(indices + indices.reversed())

        return try! MeshResource.generate(from: [descriptor])
    }
}
