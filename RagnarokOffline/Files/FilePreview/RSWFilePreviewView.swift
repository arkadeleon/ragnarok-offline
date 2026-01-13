//
//  RSWFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/25.
//

import RagnarokFileFormats
import RagnarokReality
import RagnarokResources
import RealityKit
import SGLMath
import SwiftUI

struct RSWFilePreviewView: View {
    var file: File

    private enum ViewMode {
        case world
        case tree
    }

    @State private var viewMode: ViewMode = .world

    var body: some View {
        Group {
            switch viewMode {
            case .world:
                RSWFileWorldView(file: file)
            case .tree:
                FileJSONViewer(file: file)
            }
        }
        .toolbar {
            Menu {
                Picker("View Mode", selection: $viewMode) {
                    Label("World", systemImage: "map")
                        .tag(ViewMode.world)
                    Label("Tree", systemImage: "list.bullet.indent")
                        .tag(ViewMode.tree)
                }
            } label: {
                Image(systemName: "ellipsis")
            }
        }
    }
}

struct RSWFileWorldView: View {
    var file: File

    private let progress = Progress()

    @State private var translation: CGSize = .zero
    @State private var magnification: CGFloat = 1

    var body: some View {
        AsyncContentView {
            try await loadRSWFile()
        } content: { entity in
            ModelViewer(entity: entity)
        } placeholder: {
            ProgressView(progress)
                .progressViewStyle(.circular)
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
        case .grfArchiveNode(let grfArchive, let node) where !node.isDirectory:
            let gatPath = node.path.replacingExtension("gat")
            gatData = try await grfArchive.contentsOfEntryNode(at: gatPath)

            let gndPath = node.path.replacingExtension("gnd")
            gndData = try await grfArchive.contentsOfEntryNode(at: gndPath)
        default:
            throw FileError.fileIsDirectory
        }

        let gat = try GAT(data: gatData)
        let gnd = try GND(data: gndData)

        let world = WorldResource(gat: gat, gnd: gnd, rsw: rsw)

        let worldEntity = try await Entity(from: world, resourceManager: .shared, progress: progress)

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
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
