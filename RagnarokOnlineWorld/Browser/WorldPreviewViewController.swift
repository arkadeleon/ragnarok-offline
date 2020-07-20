//
//  WorldPreviewViewController.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/6/23.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit
import MetalKit
import SGLMath

class WorldPreviewViewController: UIViewController {

    let source: DocumentSource

    private var mtkView: MTKView!
    private var renderer: WorldPreviewRenderer!

    init(source: DocumentSource) {
        self.source = source
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        mtkView = MTKView()
        view = mtkView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = source.name
        edgesForExtendedLayout = []

        view.backgroundColor = .systemBackground

        loadSource()
    }

    private func loadSource() {
        DispatchQueue.global().async {
            guard case .entry(let url, _) = self.source,
                  let data = try? self.source.data()
            else {
                return
            }

            let loader = DocumentLoader()
            guard let rsw = try? loader.load(RSWDocument.self, from: data) else {
                return
            }

            guard let gatData = try? ResourceManager.default.contentsOfEntry(withName: "data\\" + rsw.files.gat, preferredURL: url),
                  let gat = try? loader.load(GATDocument.self, from: gatData)
            else {
                return
            }

            guard let gndData = try? ResourceManager.default.contentsOfEntry(withName: "data\\" + rsw.files.gnd, preferredURL: url),
                  let gnd = try? loader.load(GNDDocument.self, from: gndData)
            else {
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
                return
            }

            context.setFillColor(UIColor.black.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: Int(ATLAS_WIDTH), height: Int(ATLAS_HEIGHT)))

            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: CGFloat(Int(ATLAS_HEIGHT)))
            context.concatenate(flipVertical)

            for (i, name) in textures.enumerated() {
                guard let data = try? ResourceManager.default.contentsOfEntry(withName: "data\\texture\\" + name) else {
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
                let data = try? ResourceManager.default.contentsOfEntry(withName: name as String)
                waterTextures.append(data)
            }

            var models: [String: ([[ModelVertex]], [Data?])] = [:]
            for model in rsw.models {
                let name = "data\\model\\" + model.filename
                guard let data = try? ResourceManager.default.contentsOfEntry(withName: name, preferredURL: url),
                      let rsm = try? loader.load(RSMDocument.self, from: data) else {
                    continue
                }

                var m = models[name] ?? ([[ModelVertex]](repeating: [], count: rsm.textures.count), [])

                let textures = rsm.textures.map { textureName -> Data? in
                    return try? ResourceManager.default.contentsOfEntry(withName: "data\\texture\\" + textureName)
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

            DispatchQueue.main.async {
                guard let renderer = try? WorldPreviewRenderer(altitude: altitude, vertices: state.mesh, texture: jpeg, waterVertices: state.waterMesh, waterTextures: waterTextures, modelMeshes: modelMeshes, modelTextures: modelTextures) else {
                    return
                }

                self.renderer = renderer

                self.mtkView.device = renderer.device
                self.mtkView.colorPixelFormat = Formats.colorPixelFormat
                self.mtkView.depthStencilPixelFormat = Formats.depthPixelFormat
                self.mtkView.delegate = renderer

                self.mtkView.addGestureRecognizer(renderer.camera.panGestureRecognizer)
                self.mtkView.addGestureRecognizer(renderer.camera.twoFingerPanGestureRecognizer)
                self.mtkView.addGestureRecognizer(renderer.camera.pinchGestureRecognizer)
                self.mtkView.addGestureRecognizer(renderer.camera.rotationGestureRecognizer)
            }
        }
    }
}
