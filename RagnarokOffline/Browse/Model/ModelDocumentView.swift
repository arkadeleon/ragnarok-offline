//
//  ModelDocumentView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/7.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct ModelDocumentView: View {

    enum Status {
        case notYetLoaded
        case loading
        case loaded(ModelDocumentRenderer)
        case failed
    }

    let document: DocumentWrapper

    @State private var status: Status = .notYetLoaded
    @State private var magnification = 1.0

    var body: some View {
        ZStack {
            if case .loaded(let renderer) = status {
                MetalView(renderer: renderer)
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
        .overlay {
            if case .loading = status {
                ProgressView()
            }
        }
        .navigationTitle(document.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await load()
        }
    }

    func load() async {
        guard case .notYetLoaded = status else {
            return
        }

        status = .loading

        guard case .grfEntry(let grf, _) = self.document,
              let data = self.document.contents()
        else {
            status = .failed
            return
        }

        guard let rsm = try? RSMDocument(data: data) else {
            status = .failed
            return
        }

        let textures = rsm.textures.map { textureName -> Data? in
            let path = GRF.Path(string: "data\\texture\\" + textureName)
            return try? grf.contentsOfEntry(at: path)
        }

        let (boundingBox, wrappers) = rsm.calcBoundingBox()

        let instance = rsm.createInstance(
            position: [0, 0, 0],
            rotation: [0, 0, 0],
            scale: [-0.075, -0.075, -0.075],
            width: 0,
            height: 0
        )

        let meshes = rsm.compile(instance: instance, wrappers: wrappers, boundingBox: boundingBox)

        guard let renderer = try? ModelDocumentRenderer(meshes: meshes, textures: textures, boundingBox: boundingBox) else {
            status = .failed
            return
        }

        status = .loaded(renderer)
    }
}
