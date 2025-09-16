//
//  RSWFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/25.
//

import FileFormats
import RealityKit
import RORendering
import ROResources
import SGLMath
import SwiftUI

struct RSWFilePreviewView: View {
    var file: File

    @State private var translation: CGSize = .zero
    @State private var magnification: CGFloat = 1

    var body: some View {
        AsyncContentView {
            try await loadRSWFile()
        } content: { entity in
            ModelViewer(entity: entity)
        }
    }

    private func loadRSWFile() async throws -> Entity {
        let rswData = try await file.contents()
        let rsw = try RSW(data: rswData)

        let gatData: Data
        let gndData: Data
        switch file.node {
        case .regularFile(let url):
            let gatURL = url.deletingPathExtension().appendingPathExtension("gat")
            gatData = try Data(contentsOf: gatURL)

            let gndURL = url.deletingPathExtension().appendingPathExtension("gnd")
            gndData = try Data(contentsOf: gndURL)
        case .grfArchiveEntry(let grfArchive, let entry):
            let gatPath = entry.path.replacingExtension("gat")
            gatData = try await grfArchive.contentsOfEntry(at: gatPath)

            let gndPath = entry.path.replacingExtension("gnd")
            gndData = try await grfArchive.contentsOfEntry(at: gndPath)
        default:
            throw FileError.fileIsDirectory
        }

        let gat = try GAT(data: gatData)
        let gnd = try GND(data: gndData)

        let world = WorldResource(gat: gat, gnd: gnd, rsw: rsw)

        let worldEntity = try await Entity.worldEntity(world: world, resourceManager: .shared)

        let translation = simd_float4x4(translation: [-Float(gat.width / 2), 0, -Float(gat.height / 2)])
        let rotation = simd_float4x4(rotationX: radians(-90))
        let scaleFactor = 2 / Float(max(gat.width, gat.height))
        let scale = simd_float4x4(scale: [scaleFactor, scaleFactor, scaleFactor])

        worldEntity.transform.matrix = scale * rotation * translation

        let entity = Entity()
        entity.addChild(worldEntity)

        return entity
    }
}

#Preview {
    AsyncContentView {
        try await File.previewRSW()
    } content: { file in
        RSWFilePreviewView(file: file)
    }
    .frame(width: 400, height: 300)
}
