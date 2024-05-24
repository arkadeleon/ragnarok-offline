//
//  RSWFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/25.
//

import MetalKit
import SwiftUI
import ROFileFormats
import RORenderers

struct RSWFilePreviewView: View {
    var file: ObservableFile

    @State private var status: AsyncContentStatus<RSWRenderer> = .notYetLoaded
    @State private var translation: CGSize = .zero
    @State private var magnification: CGFloat = 1

    var body: some View {
        AsyncContentView(status: status) { renderer in
            MetalViewContainer(renderer: renderer)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let offset = CGPoint(x: translation.width + value.translation.width, y: translation.height - value.translation.height)
                            renderer.camera.move(offset: offset)
                        }
                        .onEnded { value in
                            translation.width += value.translation.width
                            translation.height -= value.translation.height
                        }
                )
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
            await loadRSWFile()
        }
    }

    private func loadRSWFile() async {
        guard case .notYetLoaded = status else {
            return
        }

        status = .loading

        guard case .grfEntry(let grf, _) = file.file, let data = file.file.contents() else {
            return
        }

        guard let rsw = try? RSW(data: data) else {
            return
        }

        let gatPath = GRF.Path(string: "data\\" + rsw.files.gat)
        guard let gatData = try? grf.contentsOfEntry(at: gatPath),
              let gat = try? GAT(data: gatData)
        else {
            return
        }

        let gndPath = GRF.Path(string: "data\\" + rsw.files.gnd)
        guard let gndData = try? grf.contentsOfEntry(at: gndPath),
              let gnd = try? GND(data: gndData)
        else {
            return
        }

        let device = MTLCreateSystemDefaultDevice()!
        let textureLoader = MTKTextureLoader(device: device)

        let ground = Ground(gat: gat, gnd: gnd) { textureName in
            let path = GRF.Path(string: "data\\texture\\" + textureName)
            guard let data = try? grf.contentsOfEntry(at: path) else {
                return nil
            }
            let texture = textureLoader.newTexture(bmpData: data)
            return texture
        }

        let water = Water(gnd: gnd, rsw: rsw) { textureName in
            let path = GRF.Path(string: "data\\texture\\" + textureName)
            guard let data = try? grf.contentsOfEntry(at: path) else {
                return nil
            }
            let texture = textureLoader.newTexture(bmpData: data)
            return texture
        }

        var models: [Model] = []
        var modelTextures: [String : MTLTexture] = [:]

        for model in rsw.models {
            let path = GRF.Path(string: "data\\model\\" + model.modelName)
            guard let data = try? grf.contentsOfEntry(at: path),
                  let rsm = try? RSM(data: data) else {
                continue
            }

            let instance = Model.createInstance(
                position: model.position,
                rotation: model.rotation,
                scale: model.scale,
                width: Float(gnd.width),
                height: Float(gnd.height)
            )

            let model = Model(rsm: rsm, instance: instance) { textureName in
                if let texture = modelTextures[textureName] {
                    return texture
                }
                let path = GRF.Path(string: "data\\texture\\" + textureName)
                guard let data = try? grf.contentsOfEntry(at: path) else {
                    return nil
                }
                let texture = textureLoader.newTexture(bmpData: data)
                modelTextures[textureName] = texture
                return texture
            }

            models.append(model)
        }

        guard let renderer = try? RSWRenderer(device: device, ground: ground, water: water, models: models) else {
            return
        }

        status = .loaded(renderer)
    }
}

//#Preview {
//    RSWFilePreviewView(file: <#T##File#>)
//}
