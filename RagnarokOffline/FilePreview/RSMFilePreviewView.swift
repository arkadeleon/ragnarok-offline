//
//  RSMFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/25.
//

import MetalKit
import SwiftUI
import ROFileFormats
import ROFileSystem
import RORenderers

struct RSMFilePreviewView: View {
    let file: File

    @State private var status: AsyncContentStatus<RSMRenderer> = .notYetLoaded
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
            await loadRSMFile()
        }
    }

    private func loadRSMFile() async {
        guard case .notYetLoaded = status else {
            return
        }

        status = .loading

        guard case .grfEntry(let grf, _) = file, let data = file.contents() else {
            return
        }

        guard let rsm = try? RSM(data: data) else {
            return
        }

        let device = MTLCreateSystemDefaultDevice()!
        let textureLoader = MTKTextureLoader(device: device)

        let instance = Model.createInstance(
            position: [0, 0, 0],
            rotation: [0, 0, 0],
            scale: [-0.25, -0.25, -0.25],
            width: 0,
            height: 0
        )

        let model = Model(rsm: rsm, instance: instance) { textureName in
            let path = GRF.Path(string: "data\\texture\\" + textureName)
            guard let data = try? grf.contentsOfEntry(at: path) else {
                return nil
            }
            let texture = textureLoader.newTexture(bmpData: data)
            return texture
        }

        guard let renderer = try? RSMRenderer(device: device, model: model) else {
            return
        }

        status = .loaded(renderer)
    }
}

//#Preview {
//    RSMFilePreviewView(file: <#T##File#>)
//}
