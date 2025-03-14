//
//  RSMFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/25.
//

import RealityKit
import ROCore
import ROFileFormats
import RORenderers
import SwiftUI

struct RSMFilePreviewView: View {
    var file: File

    var body: some View {
        AsyncContentView(load: loadRSMFile) { entity in
            ModelViewer(entity: entity)
        }
    }

    nonisolated private func loadRSMFile() async throws -> Entity {
        guard case .grfEntry(let grf, _) = file.node, let data = await file.contents() else {
            throw FilePreviewError.invalidRSMFile
        }

        let rsm = try RSM(data: data)

        let instance = Model.createInstance(
            position: .zero,
            rotation: .zero,
            scale: [-0.25, -0.25, -0.25],
            width: 0,
            height: 0
        )

        let entity = try await Entity.loadModel(rsm: rsm, instance: instance) { textureName in
            let path = GRFPath(components: ["data", "texture", textureName])
            guard let data = try? grf.contentsOfEntry(at: path) else {
                return nil
            }
            let texture = CGImageCreateWithData(data)
            return texture?.removingMagentaPixels()
        }

        return entity
    }
}

#Preview {
    RSMFilePreviewView(file: .previewRSM)
}
