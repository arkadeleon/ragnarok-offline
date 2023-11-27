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

    private var magnification: CGFloat = 1
    private var offset: CGPoint = .zero

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

            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
            mtkView.addGestureRecognizer(pinchGestureRecognizer)

            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            mtkView.addGestureRecognizer(panGestureRecognizer)

//            mtkView.addGestureRecognizer(renderer.camera.twoFingerPanGestureRecognizer)
//            mtkView.addGestureRecognizer(renderer.camera.rotationGestureRecognizer)

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

    @objc private func handlePinch(_ pinchGestureRecognizer: UIPinchGestureRecognizer) {
        switch pinchGestureRecognizer.state {
        case .changed:
            let magnification = magnification * pinchGestureRecognizer.scale
            renderer.camera.update(magnification: magnification, dragTranslation: .zero)
        case .ended:
            magnification = magnification * pinchGestureRecognizer.scale
        default:
            break
        }
    }

    @objc private func handlePan(_ panGestureRecognizer: UIPanGestureRecognizer) {
        switch panGestureRecognizer.state {
        case .changed:
            let translation = panGestureRecognizer.translation(in: panGestureRecognizer.view)
            let offset = CGPoint(x: offset.x + translation.x, y: offset.y - translation.y)
            renderer.camera.move(offset: offset)
        case .ended:
            let translation = panGestureRecognizer.translation(in: panGestureRecognizer.view)
            offset = CGPoint(x: offset.x + translation.x, y: offset.y - translation.y)
        default:
            break
        }
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

        let device = MTLCreateSystemDefaultDevice()!
        let textureLoader = TextureLoader(device: device)

        let ground = Ground(gat: gat, gnd: gnd) { textureName in
            let path = GRF.Path(string: "data\\texture\\" + textureName)
            guard let data = try? grf.contentsOfEntry(at: path) else {
                return nil
            }
            let texture = textureLoader.newTexture(data: data)
            return texture
        }

        let water = Water(gnd: gnd, rsw: rsw) { textureName in
            let path = GRF.Path(string: "data\\texture\\" + textureName)
            guard let data = try? grf.contentsOfEntry(at: path) else {
                return nil
            }
            let texture = textureLoader.newTexture(data: data)
            return texture
        }

        var modelTextures: [String : MTLTexture] = [:]
        var models: [String : ModelMesh] = [:]

        for model in rsw.models {
            let path = GRF.Path(string: "data\\model\\" + model.modelName)
            guard let data = try? grf.contentsOfEntry(at: path),
                  let rsm = try? RSM(data: data) else {
                continue
            }

            let (boundingBox, wrappers) = rsm.calcBoundingBox()

            let instance = rsm.createInstance(
                position: model.position,
                rotation: model.rotation,
                scale: model.scale,
                width: Float(gnd.width),
                height: Float(gnd.height)
            )

            let meshes = rsm.compile(instance: instance, wrappers: wrappers, boundingBox: boundingBox) { textureName in
                if let texture = modelTextures[textureName] {
                    return texture
                }
                let path = GRF.Path(string: "data\\texture\\" + textureName)
                guard let data = try? grf.contentsOfEntry(at: path) else {
                    return nil
                }
                let texture = textureLoader.newTexture(data: data)
                modelTextures[textureName] = texture
                return texture
            }

            for (i, mesh) in meshes.enumerated() {
                let textureName = rsm.textures[i]
                var m = models[textureName] ?? ModelMesh(texture: mesh.texture)
                m.vertices += mesh.vertices
                models[textureName] = m
            }
        }

        guard let renderer = try? RSWRenderer(device: device, ground: ground, water: water, modelMeshes: Array(models.values)) else {
            return nil
        }

        return renderer
    }
}
