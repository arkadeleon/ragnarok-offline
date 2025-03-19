//
//  GNDFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/16.
//

import RealityKit
import ROCore
import ROFileFormats
import ROResources
import SwiftUI

struct GNDFilePreviewView: View {
    var file: File

    var body: some View {
        AsyncContentView(load: loadGNDFile) { entity in
            ModelViewer(entity: entity)
        }
    }

    nonisolated private func loadGNDFile() async throws -> Entity {
        guard let data = await file.contents() else {
            throw FilePreviewError.invalidGNDFile
        }

        let gnd = try GND(data: data)

        let gatData: Data
        switch file.node {
        case .regularFile(let url):
            let gatPath = url.deletingPathExtension().path().appending(".gat")
            gatData = try Data(contentsOf: URL(filePath: gatPath))
        case .grfEntry(let grf, let path):
            let gatPath = path.replacingExtension("gat")
            gatData = try grf.contentsOfEntry(at: gatPath)
        default:
            throw FilePreviewError.invalidACTFile
        }

        let gat = try GAT(data: gatData)

        let groundEntity = try await Entity.groundEntity(gat: gat, gnd: gnd)

        let translation = simd_float4x4(translation: [-Float(gat.width / 2), 0, -Float(gat.height / 2)])
        let rotation = simd_float4x4(rotationX: radians(-90))
        let scaleFactor = 1 / Float(max(gat.width, gat.height))
        let scale = simd_float4x4(scale: [scaleFactor, scaleFactor, scaleFactor])

        await MainActor.run {
            groundEntity.transform.matrix = scale * rotation * translation
        }

        let entity = await Entity()
        await entity.addChild(groundEntity)

        return entity
    }
}

#Preview {
    GNDFilePreviewView(file: .previewGND)
}
