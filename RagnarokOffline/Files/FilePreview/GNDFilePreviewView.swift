//
//  GNDFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/16.
//

import RagnarokFileFormats
import RagnarokRenderAssets
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

                NavigationLink {
                    GNDFileTextureAtlasView(file: file)
                } label: {
                    Label(String("Texture Atlas"), systemImage: "photo")
                }

                NavigationLink {
                    GNDFileLightmapAtlasView(file: file)
                } label: {
                    Label(String("Lightmap Atlas"), systemImage: "photo")
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

        let textureImages = await ResourceManager.shared.textureImages(forNames: gnd.textures, removesMagentaPixels: false) { _, _ in
            progress.completedUnitCount += 1
        }

        let ground = Ground(gat: gat, gnd: gnd)
        let groundEntity = try await Entity(
            from: ground,
            lighting: .preview,
            textureImages: textureImages
        )

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

struct GNDFileTextureAtlasView: View {
    var file: File

    private let progress = Progress()

    var body: some View {
        AsyncContentView {
            try await loadGNDTextureAtlasImage()
        } content: { image in
            Image(decorative: image, scale: 1)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            ProgressView(progress)
                .progressViewStyle(.circular)
        }
    }

    private func loadGNDTextureAtlasImage() async throws -> CGImage {
        let gndData = try await file.contents()
        let gnd = try GND(data: gndData)

        progress.totalUnitCount = Int64(gnd.textures.count)
        progress.completedUnitCount = 0

        let textureImages = await ResourceManager.shared.textureImages(forNames: gnd.textures, removesMagentaPixels: false) { _, _ in
            progress.completedUnitCount += 1
        }

        let textureAtlas = GroundTextureAtlas(gnd: gnd)
        guard let image = textureAtlas.makeCGImage(textureImages: textureImages) else {
            throw FileError.imageGenerationFailed
        }

        return image
    }
}

struct GNDFileLightmapAtlasView: View {
    var file: File

    var body: some View {
        AsyncContentView {
            try await loadGNDLightmapAtlasImage()
        } content: { image in
            Image(decorative: image, scale: 1)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }

    private func loadGNDLightmapAtlasImage() async throws -> CGImage {
        let gndData = try await file.contents()
        let gnd = try GND(data: gndData)

        let lightmapAtlas = GroundLightmapAtlas(lightmap: gnd.lightmap)
        guard let image = lightmapAtlas.makeCGImage() else {
            throw FileError.imageGenerationFailed
        }

        return image
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
