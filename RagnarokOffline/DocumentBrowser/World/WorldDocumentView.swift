//
//  WorldDocumentView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/7.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct WorldDocumentView: View {

    enum Status {
        case notYetLoaded
        case loading
        case loaded(WorldDocumentRenderer)
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
        guard let rsw = try? loader.load(RSWDocument.self, from: data) else {
            status = .failed
            return
        }

        guard let gatData = grf.node(atPath: "data\\" + rsw.files.gat)?.contents,
              let gat = try? loader.load(GATDocument.self, from: gatData)
        else {
            status = .failed
            return
        }

        guard let gndData = grf.node(atPath: "data\\" + rsw.files.gnd)?.contents,
              let gnd = try? loader.load(GNDDocument.self, from: gndData)
        else {
            status = .failed
            return
        }

        let altitude = gat.compile()
        let state = gnd.compile(WATER_LEVEL: rsw.water.level, WATER_HEIGHT: rsw.water.waveHeight)

        let textures = gnd.textures

        let ATLAS_COLS         = roundf(sqrtf(Float(textures.count)))
        let ATLAS_ROWS         = ceilf(sqrtf(Float(textures.count)))
        let ATLAS_WIDTH        = powf(2, ceilf(logf(ATLAS_COLS * 258) / logf(2)))
        let ATLAS_HEIGHT       = powf(2, ceilf(logf(ATLAS_ROWS * 258) / logf(2)))

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue | CGImageByteOrderInfo.order32Little.rawValue

        guard let context = CGContext(
            data: nil,
            width: Int(ATLAS_WIDTH),
            height: Int(ATLAS_HEIGHT),
            bitsPerComponent: 8,
            bytesPerRow: Int(ATLAS_WIDTH) * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            status = .failed
            return
        }

        context.setFillColor(UIColor.black.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: Int(ATLAS_WIDTH), height: Int(ATLAS_HEIGHT)))

        let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: CGFloat(Int(ATLAS_HEIGHT)))
        context.concatenate(flipVertical)

        for (i, name) in textures.enumerated() {
            guard let data = grf.node(atPath: "data\\texture\\" + name)?.contents else {
                continue
            }
            let image = UIImage(data: data)?.cgImage?.decoded

            let x = (i % Int(ATLAS_COLS)) * 258
            let y = (i / Int(ATLAS_COLS)) * 258
            context.draw(image!, in: CGRect(x: x, y: y, width: 258, height: 258))
            context.draw(image!, in: CGRect(x: x + 0, y: y + 0, width: 256, height: 256))
        }

        let jpeg = UIImage(cgImage: context.makeImage()!).jpegData(compressionQuality: 1.0)!

        var waterTextures: [Data?] = []
        for i in 0..<32 {
            let name = NSString(format: "data\\texture\\워터\\water0%02d.jpg", i)
            let data = grf.node(atPath: name as String)?.contents
            waterTextures.append(data)
        }

        var models: [String: ([[ModelVertex]], [Data?])] = [:]
        for model in rsw.models {
            let name = "data\\model\\" + model.filename
            guard let data = grf.node(atPath: name)?.contents,
                  let rsm = try? loader.load(RSMDocument.self, from: data) else {
                continue
            }

            var m = models[name] ?? ([[ModelVertex]](repeating: [], count: rsm.textures.count), [])

            let textures = rsm.textures.map { textureName -> Data? in
                grf.node(atPath: "data\\texture\\" + textureName)?.contents
            }
            m.1 = textures

            let (boundingBox, wrappers) = rsm.calcBoundingBox()

            let instance = rsm.createInstance(
                position: model.position,
                rotation: model.rotation,
                scale: model.scale,
                width: Float(gnd.width),
                height: Float(gnd.height)
            )

            let meshes = rsm.compile(instance: instance, wrappers: wrappers, boundingBox: boundingBox)
            for (i, mesh) in meshes.enumerated() {
                m.0[i].append(contentsOf: mesh)
            }

            models[name] = m
        }

        var modelMeshes: [[ModelVertex]] = []
        var modelTextures: [Data?] = []
        for value in models.values {
            modelMeshes.append(contentsOf: value.0)
            modelTextures.append(contentsOf: value.1)
        }

        guard let renderer = try? WorldDocumentRenderer(altitude: altitude, vertices: state.mesh, texture: jpeg, waterVertices: state.waterMesh, waterTextures: waterTextures, modelMeshes: modelMeshes, modelTextures: modelTextures) else {
            status = .failed
            return
        }

        status = .loaded(renderer)

//        self.mtkView.addGestureRecognizer(renderer.camera.panGestureRecognizer)
//        self.mtkView.addGestureRecognizer(renderer.camera.twoFingerPanGestureRecognizer)
//        self.mtkView.addGestureRecognizer(renderer.camera.pinchGestureRecognizer)
//        self.mtkView.addGestureRecognizer(renderer.camera.rotationGestureRecognizer)
    }
}
