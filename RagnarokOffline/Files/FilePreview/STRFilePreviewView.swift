//
//  STRFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/26.
//

import MetalKit
import ROFileFormats
import RORenderers
import SwiftUI

struct STRFilePreviewView: View {
    var file: File

    @State private var magnification: CGFloat = 1

    var body: some View {
        AsyncContentView(load: loadSTRFile) { renderer in
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

    nonisolated private func loadSTRFile() async throws -> STRRenderer {
        guard case .grfArchiveEntry(let grfArchive, let entry) = file.node, let data = await file.contents() else {
            throw FilePreviewError.invalidSTRFile
        }

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

                let texturePath = entry.path.parent.appending([textureName])
                guard let data = try? await grfArchive.contentsOfEntry(at: texturePath) else {
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
