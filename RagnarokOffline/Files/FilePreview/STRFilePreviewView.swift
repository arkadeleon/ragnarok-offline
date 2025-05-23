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
        guard case .grfEntry(let grf, let path) = file.node, let data = await file.contents() else {
            throw FilePreviewError.invalidSTRFile
        }

        let str = try STR(data: data)

        let device = MTLCreateSystemDefaultDevice()!
        let textureLoader = MTKTextureLoader(device: device)

        var texturesByName: [String : any MTLTexture] = [:]

        let effect = Effect(str: str) { textureName in
            if let texture = texturesByName[textureName] {
                return texture
            }
            let texturePath = path.parent.appending([textureName])
            guard let data = try? grf.contentsOfEntry(at: texturePath) else {
                return nil
            }
            let texture = textureLoader.newTexture(bmpData: data)
            texturesByName[textureName] = texture
            return texture
        }

        let renderer = try STRRenderer(device: device, effect: effect)
        return renderer
    }
}

//#Preview {
//    STRFilePreviewView(file: <#T##File#>)
//}
