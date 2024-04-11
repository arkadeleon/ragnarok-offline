//
//  RSMPreviewViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/20.
//

import MetalKit
import UIKit
import ROFileFormats
import ROFileSystem
import RORenderers

class RSMPreviewViewController: UIViewController {
    let file: File

    private var mtkView: MTKView!
    private var activityIndicatorView: UIActivityIndicatorView!

    private var renderer: RSMRenderer!

    private var magnification: CGFloat = 1

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

    nonisolated private func loadRenderer() async -> RSMRenderer? {
        guard case .grfEntry(let grf, _) = file, let data = file.contents() else {
            return nil
        }

        guard let rsm = try? RSM(data: data) else {
            return nil
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
            return nil
        }

        return renderer
    }
}
