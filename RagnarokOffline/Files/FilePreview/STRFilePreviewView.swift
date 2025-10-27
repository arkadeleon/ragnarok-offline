//
//  STRFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/26.
//

import RagnarokFileFormats
import MetalKit
import RagnarokRenderers
import SwiftUI

struct STRFilePreviewView: View {
    var file: File

    @State private var magnification: CGFloat = 1

    var body: some View {
        AsyncContentView {
            try await loadSTRFile()
        } content: { renderer in
            #if os(visionOS)
            EmptyView()
            #else
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
            #endif
        }
    }

    private func loadSTRFile() async throws -> STRRenderer {
        guard case .grfArchiveNode(let grfArchive, let node) = file.node, !node.isDirectory else {
            throw FileError.fileIsDirectory
        }

        let data = try await file.contents()
        let str = try STR(data: data)
        let effect = Effect(str: str)

        let device = MTLCreateSystemDefaultDevice()!
        let textureLoader = MTKTextureLoader(device: device)
        var textures: [String : any MTLTexture] = [:]

        for frame in effect.frames {
            for sprite in frame.sprites {
                let textureName = sprite.textureName
                if let _ = textures[textureName] {
                    continue
                }

                let texturePath = node.path.replacingLastComponent(textureName)
                guard let data = try? await grfArchive.contentsOfEntryNode(at: texturePath) else {
                    continue
                }

                if let texture = textureLoader.newTexture(bmpData: data) {
                    textures[textureName] = texture
                }
            }
        }

        let renderer = try STRRenderer(device: device, effect: effect, textures: textures)
        return renderer
    }
}

//#Preview {
//    STRFilePreviewView(file: <#T##File#>)
//}
