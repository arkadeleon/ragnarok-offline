//
//  RSMFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/25.
//

import RagnarokFileFormats
import RagnarokReality
import RagnarokRenderAssets
import RagnarokRenderers
import RagnarokResources
import SwiftUI

struct RSMFilePreviewView: View {
    var file: File
    var resourceManager: ResourceManager

    private enum ViewMode {
        case model
        case tree
    }

    @State private var viewMode: ViewMode = .model

    var body: some View {
        Group {
            switch viewMode {
            case .model:
                RSMFileModelView(file: file, resourceManager: resourceManager)
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

#if os(visionOS)

import RealityKit

struct RSMFileModelView: View {
    var file: File
    var resourceManager: ResourceManager

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
            scale: [-0.25, -0.25, -0.25] / 5
        )

        var textureNames: Set<String> = []
        for node in rsm.nodes {
            textureNames.formUnion(node.textures)
        }

        progress.totalUnitCount = Int64(textureNames.count)
        progress.completedUnitCount = 0

        let textureImages = await resourceManager.textureImages(forNames: textureNames, removesMagentaPixels: true) { _, _ in
            progress.completedUnitCount += 1
        }

        let modelAsset = RSMModelRenderAsset(
            name: file.name,
            rsm: rsm,
            instance: instance,
            textureImages: textureImages
        )
        let modelEntity = try await Entity(from: modelAsset)
        modelEntity.scale *= instance.scale
        return modelEntity
    }
}

#else

import Metal

struct RSMFileModelView: View {
    var file: File
    var resourceManager: ResourceManager

    private let progress = Progress()

    @State private var magnification: CGFloat = 1

    var body: some View {
        AsyncContentView {
            try await loadRSMFile()
        } content: { renderer in
            MetalViewContainer(renderer: renderer)
                .gesture(
                    MagnifyGesture()
                        .onChanged { value in
                            renderer.camera.update(magnification: magnification * value.magnification, dragTranslation: .zero)
                        }
                        .onEnded { value in
                            magnification *= value.magnification
                        }
                )
        } placeholder: {
            ProgressView(progress)
                .progressViewStyle(.circular)
        }
    }

    private func loadRSMFile() async throws -> RSMFilePreviewRenderer {
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

        let textureImages = await resourceManager.textureImages(forNames: textureNames, removesMagentaPixels: true) { _, _ in
            progress.completedUnitCount += 1
        }

        let modelAsset = RSMModelRenderAsset(
            name: file.name,
            rsm: rsm,
            instance: instance,
            textureImages: textureImages
        )

        let device = MTLCreateSystemDefaultDevice()!
        let renderer = try RSMFilePreviewRenderer(device: device, asset: modelAsset)
        return renderer
    }
}

#endif

#Preview {
    AsyncContentView {
        try await File.previewRSM()
    } content: { file in
        RSMFilePreviewView(file: file, resourceManager: .previewing)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
