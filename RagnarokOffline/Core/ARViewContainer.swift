//
//  ARViewContainer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/16.
//

import RealityKit
import SwiftUI

struct ARViewContainer: UIViewRepresentable {
    let entity: Entity

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        arView.environment.background = .color(.systemBackground)

        let lightEntity = DirectionalLight()
        lightEntity.light.color = .white
        lightEntity.light.intensity = 20000
        lightEntity.look(at: .zero, from: [0, 0, 2], relativeTo: nil)

        let cameraEntity = PerspectiveCamera()
        cameraEntity.camera.fieldOfViewInDegrees = 60
        cameraEntity.look(at: .zero, from: [0, 0, 2], relativeTo: nil)

        let worldAnchor = AnchorEntity(world: .zero)
        worldAnchor.addChild(entity)
        worldAnchor.addChild(cameraEntity)
        worldAnchor.addChild(lightEntity)
        arView.scene.addAnchor(worldAnchor)

        return arView
    }

    func updateUIView(_ arView: ARView, context: Context) {
    }
}

#Preview {
    ARViewContainer(entity: Entity())
}
