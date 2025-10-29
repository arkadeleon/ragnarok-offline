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

    var body: some View {
        AsyncContentView {
            try await loadRSMFile()
        } content: { entity in
            ModelViewer(entity: entity)
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
        let textures = await ResourceManager.shared.textures(forNames: textureNames, removesMagentaPixels: true)

        let entity = try await Entity.modelEntity(rsm: rsm, instance: instance, textures: textures)
        return entity
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
