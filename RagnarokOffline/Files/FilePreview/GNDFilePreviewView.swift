//
//  GNDFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/16.
//

import RagnarokFileFormats
import RagnarokRenderers
import RagnarokResources
import RealityKit
import SGLMath
import SwiftUI

struct GNDFilePreviewView: View {
    var file: File

    private enum ViewMode {
        case ground
        case tree
    }

    @State private var viewMode: ViewMode = .ground

    var body: some View {
        Group {
            switch viewMode {
            case .ground:
                GNDFileGroundView(file: file)
            case .tree:
                FileJSONViewer(file: file)
            }
        }
        .toolbar {
            Menu {
                Picker("View Mode", selection: $viewMode) {
                    Label("Ground", systemImage: "mountain.2")
                        .tag(ViewMode.ground)
                    Label("Tree", systemImage: "list.bullet.indent")
                        .tag(ViewMode.tree)
                }
            } label: {
                Image(systemName: "ellipsis")
            }
        }
    }
}

struct GNDFileGroundView: View {
    var file: File

    private let progress = Progress()

    var body: some View {
        AsyncContentView {
            try await loadGNDFile()
        } content: { entity in
            ModelViewer(entity: entity)
        } placeholder: {
            ProgressView(progress)
                .progressViewStyle(.circular)
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

        progress.totalUnitCount = Int64(gnd.textures.count)
        progress.completedUnitCount = 0

        let textures = await ResourceManager.shared.textures(forNames: gnd.textures, removesMagentaPixels: false) { _, _ in
            progress.completedUnitCount += 1
        }

        let ground = Ground(gat: gat, gnd: gnd)
        let groundEntity = try await Entity(from: ground, textures: textures)

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
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
