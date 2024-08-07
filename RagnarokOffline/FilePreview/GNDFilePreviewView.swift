//
//  GNDFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/16.
//

import RealityKit
import ROCore
import ROFileFormats
import RORenderers
import SwiftUI

struct GNDFilePreviewView: View {
    var file: ObservableFile

    var body: some View {
        AsyncContentView(load: loadGNDFile) { entity in
            ModelViewer(entity: entity)
        }
    }

    nonisolated private func loadGNDFile() async throws -> Entity {
        guard case .grfEntry(let grf, let path) = file.file, let data = file.file.contents() else {
            throw FilePreviewError.invalidGNDFile
        }

        let gnd = try GND(data: data)

        let gatPath = path.replacingExtension("gat")
        let gatData = try grf.contentsOfEntry(at: gatPath)
        let gat = try GAT(data: gatData)

        let groundEntity = try await Entity.loadGround(gat: gat, gnd: gnd) { textureName in
            let path = GRF.Path(string: "data\\texture\\" + textureName)
            guard let data = try? grf.contentsOfEntry(at: path) else {
                return nil
            }
            let texture = CGImageCreateWithData(data)
            return texture
        }

        let translation = float4x4(translation: [-Float(gat.width / 2), 0, -Float(gat.height / 2)])
        let rotation = float4x4(rotationX: radians(-90))
        let scaleFactor = 1 / Float(max(gat.width, gat.height))
        let scale = float4x4(scale: [scaleFactor, scaleFactor, scaleFactor])

        await MainActor.run {
            groundEntity.transform.matrix = scale * rotation * translation
        }

        let entity = await Entity()
        await entity.addChild(groundEntity)

        return entity
    }
}

#Preview {
    GNDFilePreviewView(file: PreviewFiles.gndFile)
}
