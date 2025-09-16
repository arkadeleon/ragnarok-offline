//
//  GNDFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/16.
//

import FileFormats
import RealityKit
import ROResources
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
        case .grfArchiveEntry(let grfArchive, let entry):
            let gatPath = entry.path.replacingExtension("gat")
            gatData = try await grfArchive.contentsOfEntry(at: gatPath)
        default:
            throw FileError.fileIsDirectory
        }

        let gat = try GAT(data: gatData)

        let groundEntity = try await Entity.groundEntity(gat: gat, gnd: gnd, resourceManager: .shared)

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
