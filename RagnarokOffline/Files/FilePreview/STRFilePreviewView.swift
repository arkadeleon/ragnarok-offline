//
//  STRFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/26.
//

import Metal
import RagnarokCore
import RagnarokFileFormats
import RagnarokRenderAssets
import RagnarokRendering
import SwiftUI

struct STRFilePreviewView: View {
    var file: File

    private enum ViewMode {
        case sprites
        case tree
    }

    @State private var viewMode: ViewMode = .sprites

    var body: some View {
        Group {
            switch viewMode {
            case .sprites:
                STRFileEffectView(file: file)
            case .tree:
                FileJSONViewer(file: file)
            }
        }
        .toolbar {
            Menu {
                Picker("View Mode", selection: $viewMode) {
                    Label("Effect", systemImage: "sparkles.rectangle.stack")
                        .tag(ViewMode.sprites)
                    Label("Tree", systemImage: "list.bullet.indent")
                        .tag(ViewMode.tree)
                }
            } label: {
                Image(systemName: "ellipsis")
            }
        }
    }
}

struct STRFileEffectView: View {
    var file: File

    @State private var magnification: CGFloat = 1

    var body: some View {
        AsyncContentView {
            try await loadSTRFile()
        } content: { renderer in
            MetalViewContainer(renderer: renderer)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            renderer.camera.update(magnification: magnification * value, dragTranslation: .zero)
                        }
                        .onEnded { value in
                            magnification *= value
                        }
                )
        }
    }

    private func loadSTRFile() async throws -> STRFilePreviewRenderer {
        guard case .grfArchiveNode(let grfArchive, let node) = file.node, !node.isDirectory else {
            throw FileError.fileIsDirectory
        }

        let data = try await file.contents()
        let str = try STR(data: data)

        var textureImages: [String : CGImage] = [:]
        let textureNames = Set(str.layers.flatMap(\.textures))
        for textureName in textureNames {
            let texturePath = node.path.replacingLastComponent(textureName)
            if let data = try? await grfArchive.contentsOfEntryNode(at: texturePath),
               let textureImage = CGImageCreateWithData(data)?.removingMagentaPixels() {
                textureImages[textureName] = textureImage
            }
        }

        let device = MTLCreateSystemDefaultDevice()!
        let animation = STREffectAnimation(str: str, textureImages: textureImages)
        let renderer = try STRFilePreviewRenderer(device: device, configuration: .default, animation: animation)
        return renderer
    }
}

//#Preview {
//    STRFilePreviewView(file: <#T##File#>)
//}
