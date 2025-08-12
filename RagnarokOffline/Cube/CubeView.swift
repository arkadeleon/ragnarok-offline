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
        AsyncContentView {
            try await loadCube()
        } content: { cube in
            ModelViewer(entity: cube)
        }
    }

    private func loadCube() async throws -> Entity {
        let textureResource = try await TextureResource(named: "wall")
        let texture = MaterialParameters.Texture(textureResource)

        var material = SimpleMaterial()
        material.color = SimpleMaterial.BaseColor(texture: texture)

        let mesh = MeshResource.generateBox(size: 1)
        let cube = ModelEntity(mesh: mesh, materials: [material])
        return cube
    }
}

#Preview {
    CubeView()
}
