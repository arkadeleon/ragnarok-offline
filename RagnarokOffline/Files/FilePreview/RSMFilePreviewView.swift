//
//  RSMFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/25.
//

import RagnarokFileFormats
import RagnarokRenderers
import RagnarokResources
import RealityKit
import SwiftUI

struct RSMFilePreviewView: View {
    var file: File

    private let progress = Progress()

    var body: some View {
        AsyncContentView {
            try await loadRSMFile()
        } content: { entity in
            ModelViewer(entity: entity)
        } placeholder: {
            ProgressView(progress)
                .progressViewStyle(.circular)
        }
    }

    private func loadRSMFile() async throws -> Entity {
        let data = try await file.contents()
        let rsm = try RSM(data: data)

        let instance = Model.createInstance(
            position: .zero,
            rotation: .zero,
            scale: [-0.25, -0.25, -0.25],
            width: 0,
            height: 0
        )

        var textureNames: Set<String> = []
        for node in rsm.nodes {
            textureNames.formUnion(node.textures)
        }

        progress.totalUnitCount = Int64(textureNames.count)
        progress.completedUnitCount = 0

        let textures = await ResourceManager.shared.textures(forNames: textureNames, removesMagentaPixels: true) { _, _ in
            progress.completedUnitCount += 1
        }

        let model = Model(rsm: rsm, instance: instance)
        let modelEntity = try await Entity(from: model, textures: textures)
        return modelEntity
    }
}

#Preview {
    AsyncContentView {
        try await File.previewRSM()
    } content: { file in
        RSMFilePreviewView(file: file)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
