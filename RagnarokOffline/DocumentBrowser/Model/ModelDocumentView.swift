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

    var body: some View {
        ZStack {
            if case .loaded(let renderer) = status {
                MetalView(renderer: renderer)
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

        guard case .grfNode(let grf, _) = self.document,
              let data = self.document.contents()
        else {
            status = .failed
            return
        }

        let loader = DocumentLoader()
        guard let document = try? loader.load(RSMDocument.self, from: data) else {
            status = .failed
            return
        }

        let textures = document.textures.map { textureName -> Data? in
            grf.node(atPath: "data\\texture\\" + textureName)?.contents
        }

        let (boundingBox, wrappers) = document.calcBoundingBox()

        let instance = document.createInstance(
            position: [0, 0, 0],
            rotation: [0, 0, 0],
            scale: [-0.075, -0.075, -0.075],
            width: 0,
            height: 0
        )

        let meshes = document.compile(instance: instance, wrappers: wrappers, boundingBox: boundingBox)

        guard let renderer = try? ModelDocumentRenderer(meshes: meshes, textures: textures, boundingBox: boundingBox) else {
            status = .failed
            return
        }

        status = .loaded(renderer)
    }
}
