//
//  STRFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/26.
//

import MetalKit
import SwiftUI
import ROFileFormats
import RORenderers

struct STRFilePreviewView: View {
    var file: ObservableFile

    @State private var status: AsyncContentStatus<STRRenderer> = .notYetLoaded
    @State private var magnification: CGFloat = 1

    var body: some View {
        AsyncContentView(status: status) { renderer in
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
        .task {
            await loadSTRFile()
        }
    }

    private func loadSTRFile() async {
        guard case .notYetLoaded = status else {
            return
        }

        status = .loading

        guard case .grfEntry(let grf, let path) = file.file, let data = file.file.contents() else {
            return
        }

        guard let str = try? STR(data: data) else {
            return
        }

        let device = MTLCreateSystemDefaultDevice()!
        let textureLoader = MTKTextureLoader(device: device)

        var textures: [String : MTLTexture] = [:]

        let effect = Effect(str: str) { textureName in
            if let texture = textures[textureName] {
                return texture
            }
            let texturePath = GRF.Path(string: path.parent.string + "\\" + textureName)
            guard let data = try? grf.contentsOfEntry(at: texturePath) else {
                return nil
            }
            let texture = textureLoader.newTexture(bmpData: data)
            textures[textureName] = texture
            return texture
        }

        guard let renderer = try? STRRenderer(device: device, effect: effect) else {
            return
        }

        status = .loaded(renderer)
    }
}

//#Preview {
//    STRFilePreviewView(file: <#T##File#>)
//}
