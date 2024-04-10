//
//  STRPreviewViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/24.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import MetalKit
import UIKit
import RagnarokOfflineFileFormats
import RagnarokOfflineFileSystem
import RagnarokOfflineRenderers

class STRPreviewViewController: UIViewController {
    let file: File

    private var mtkView: MTKView!
    private var activityIndicatorView: UIActivityIndicatorView!

    private var renderer: STRRenderer!

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

    nonisolated private func loadRenderer() async -> STRRenderer? {
        guard case .grfEntry(let grf, let path) = file, let data = file.contents() else {
            return nil
        }

        guard let str = try? STR(data: data) else {
            return nil
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
            return nil
        }

        return renderer
    }
}
