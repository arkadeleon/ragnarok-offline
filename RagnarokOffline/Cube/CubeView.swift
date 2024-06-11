//
//  CubeView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/15.
//

import RealityKit
import SwiftUI

struct CubeView: View {
    var body: some View {
        ModelViewer(entity: cube)
    }

    private var cube: Entity {
        let mesh = MeshResource.generateBox(size: 1)

        var material = SimpleMaterial()
        let texture = try! MaterialParameters.Texture(.load(named: "wall.jpg"))
        material.color = .init(texture: texture)

        let cube = ModelEntity(mesh: mesh, materials: [material])
        return cube
    }
}

#Preview {
    CubeView()
}
