//
//  GNDFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/16.
//

import RagnarokFileFormats
import RealityKit
import ResourceManagement
import SGLMath
import SwiftUI

struct GNDFilePreviewView: View {
    var file: File

    var body: some View {
        AsyncContentView {
            try await loadGNDFile()
        } content: { entity in
            ModelViewer(entity: entity)
        }
    }

    private func loadGNDFile() async throws -> Entity {
        let gndData = try await file.contents()
        let gnd = try GND(data: gndData)

        let gatData: Data
        switch file.node {
        case .regularFile(let url):
            let gatURL = url.deletingPathExtension().appendingPathExtension("gat")
            gatData = try Data(contentsOf: gatURL)
        case .grfArchiveNode(let grfArchive, let node) where !node.isDirectory:
            let gatPath = node.path.replacingExtension("gat")
            gatData = try await grfArchive.contentsOfEntryNode(at: gatPath)
        default:
            throw FileError.fileIsDirectory
        }

        let gat = try GAT(data: gatData)

        let textures = await ResourceManager.shared.textures(forNames: gnd.textures, removesMagentaPixels: false)

        let groundEntity = try await Entity.groundEntity(gat: gat, gnd: gnd, textures: textures)

        let translation = simd_float4x4(translation: [-Float(gat.width / 2), 0, -Float(gat.height / 2)])
        let rotation = simd_float4x4(rotationX: radians(-90))
        let scaleFactor = 2 / Float(max(gat.width, gat.height))
        let scale = simd_float4x4(scale: [scaleFactor, scaleFactor, scaleFactor])

        groundEntity.transform.matrix = scale * rotation * translation

        let entity = Entity()
        entity.addChild(groundEntity)

        return entity
    }
}

#Preview {
    AsyncContentView {
        try await File.previewGND()
    } content: { file in
        GNDFilePreviewView(file: file)
    }
    .frame(width: 400, height: 300)
}
