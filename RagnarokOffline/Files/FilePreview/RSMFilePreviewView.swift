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
        guard let data = await file.contents() else {
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

        let entity = try await Entity.modelEntity(rsm: rsm, instance: instance)
        return entity
    }
}

#Preview {
    RSMFilePreviewView(file: .previewRSM)
}
