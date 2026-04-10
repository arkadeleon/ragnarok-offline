//
//  RSMFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/25.
//

import RagnarokFileFormats
import RagnarokRendering
import RagnarokResources
import RealityKit
import SwiftUI

struct RSMFilePreviewView: View {
    var file: File

    private enum ViewMode {
        case model
        case tree
    }

    @State private var viewMode: ViewMode = .model

    var body: some View {
        Group {
            switch viewMode {
            case .model:
                RSMFileModelView(file: file)
            case .tree:
                FileJSONViewer(file: file)
            }
        }
        .toolbar {
            Menu {
                Picker("View Mode", selection: $viewMode) {
                    Label("Model", systemImage: "cube")
                        .tag(ViewMode.model)
                    Label("Tree", systemImage: "list.bullet.indent")
                        .tag(ViewMode.tree)
                }
            } label: {
                Image(systemName: "ellipsis")
            }
        }
    }
}

struct RSMFileModelView: View {
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

        let instance = RSMModelInstance(
            position: .zero,
            rotation: .zero,
            scale: [-0.25, -0.25, -0.25]
        )

        var textureNames: Set<String> = []
        for node in rsm.nodes {
            textureNames.formUnion(node.textures)
        }

        progress.totalUnitCount = Int64(textureNames.count)
        progress.completedUnitCount = 0

        let textureImages = await ResourceManager.shared.textureImages(forNames: textureNames, removesMagentaPixels: true) { _, _ in
            progress.completedUnitCount += 1
        }

        let modelAsset = RSMModelRenderAsset(
            name: file.name,
            rsm: rsm,
            instance: instance,
            lighting: .preview,
            textureImages: textureImages
        )
        let modelEntity = try await Entity(from: modelAsset)
        modelEntity.scale *= instance.scale
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
