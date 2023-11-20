//
//  RSWPreviewViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/20.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import MetalKit
import UIKit

class RSWPreviewViewController: UIViewController {
    let file: File

    private var mtkView: MTKView!
    private var activityIndicatorView: UIActivityIndicatorView!

    private var renderer: RSWRenderer!

    init(file: File) {
        self.file = file
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addActivityIndicatorView()

        activityIndicatorView.startAnimating()

        Task {
            guard let renderer = await loadRenderer() else {
                return
            }

            self.renderer = renderer

            mtkView = MTKView()
            mtkView.translatesAutoresizingMaskIntoConstraints = false
            mtkView.isOpaque = false
            mtkView.delegate = renderer
            mtkView.device = renderer.device
            mtkView.colorPixelFormat = renderer.colorPixelFormat
            mtkView.depthStencilPixelFormat = renderer.depthStencilPixelFormat
            mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
            view.addSubview(mtkView)

            mtkView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            mtkView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            mtkView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            mtkView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

            mtkView.addGestureRecognizer(renderer.camera.panGestureRecognizer)
            mtkView.addGestureRecognizer(renderer.camera.twoFingerPanGestureRecognizer)
            mtkView.addGestureRecognizer(renderer.camera.pinchGestureRecognizer)
            mtkView.addGestureRecognizer(renderer.camera.rotationGestureRecognizer)

            activityIndicatorView.stopAnimating()
        }
    }

    private func addActivityIndicatorView() {
        activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(activityIndicatorView)

        activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    nonisolated private func loadRenderer() async -> RSWRenderer? {
        guard case .grfEntry(let grf, _) = file, let data = file.contents() else {
            return nil
        }

        guard let rsw = try? RSW(data: data) else {
            return nil
        }

        let gatPath = GRF.Path(string: "data\\" + rsw.files.gat)
        guard let gatData = try? grf.contentsOfEntry(at: gatPath),
              let gat = try? GAT(data: gatData)
        else {
            return nil
        }

        let gndPath = GRF.Path(string: "data\\" + rsw.files.gnd)
        guard let gndData = try? grf.contentsOfEntry(at: gndPath),
              let gnd = try? GND(data: gndData)
        else {
            return nil
        }

        let state = gnd.compile(waterLevel: rsw.water.level, waterHeight: rsw.water.waveHeight)

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
            return nil
        }

        context.setFillColor(UIColor.black.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: Int(ATLAS_WIDTH), height: Int(ATLAS_HEIGHT)))

        let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: CGFloat(Int(ATLAS_HEIGHT)))
        context.concatenate(flipVertical)

        for (i, name) in textures.enumerated() {
            let path = GRF.Path(string: "data\\texture\\" + name)
            guard let data = try? grf.contentsOfEntry(at: path) else {
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
            let path = GRF.Path(string: String(format: "data\\texture\\워터\\water0%02d.jpg", i))
            let data = try? grf.contentsOfEntry(at: path)
            waterTextures.append(data)
        }

        var models: [String: ([[ModelVertex]], [Data?])] = [:]
        for model in rsw.models {
            let path = GRF.Path(string: "data\\model\\" + model.modelName)
            guard let data = try? grf.contentsOfEntry(at: path),
                  let rsm = try? RSMDocument(data: data) else {
                continue
            }

            var m = models[path.string] ?? ([[ModelVertex]](repeating: [], count: rsm.textures.count), [])

            let textures = rsm.textures.map { textureName -> Data? in
                let path = GRF.Path(string: "data\\texture\\" + textureName)
                return try? grf.contentsOfEntry(at: path)
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

            models[path.string] = m
        }

        var modelMeshes: [[ModelVertex]] = []
        var modelTextures: [Data?] = []
        for value in models.values {
            modelMeshes.append(contentsOf: value.0)
            modelTextures.append(contentsOf: value.1)
        }

        guard let renderer = try? RSWRenderer(gat: gat, vertices: state.mesh, texture: jpeg, waterVertices: state.waterMesh, waterTextures: waterTextures, modelMeshes: modelMeshes, modelTextures: modelTextures) else {
            return nil
        }

        return renderer
    }
}
