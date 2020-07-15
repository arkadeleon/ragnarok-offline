//
//  ModelPreviewViewController.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/12.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit
import MetalKit
import SGLMath

class ModelPreviewViewController: UIViewController {

    let source: DocumentSource

    private var mtkView: MTKView!
    private var renderer: ModelPreviewRenderer!

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
                  let grf = ResourceManager.default.grf(for: url),
                  let stream = try? FileStream(url: url),
                  let data = try? self.source.data()
            else {
                return
            }

            let loader = DocumentLoader()
            guard let document = try? loader.load(RSMDocument.self, from: data) else {
                return
            }

            let textures = document.textures.map { textureName -> Data? in
                guard let entry = grf.entry(forName: "data\\texture\\" + textureName) else {
                    return nil
                }
                guard let contents = try? grf.contents(of: entry, from: stream) else {
                    return nil
                }
                return contents
            }

            let (boundingBox, wrappers) = document.calcBoundingBox()

            let instance = document.createInstance(
                position: [0, 0, 0],
                rotation: [0, 0, 0],
                scale: [-0.075, -0.075, -0.075],
                width: 0,
                height: 0
            )

            let meshes = document.compile(instances: [instance], wrappers: wrappers, boundingBox: boundingBox)

            DispatchQueue.main.async { [self] in
                guard let renderer = try? ModelPreviewRenderer(meshes: meshes, textures: textures, boundingBox: boundingBox) else {
                    return
                }

                self.renderer = renderer

                mtkView.device = renderer.device
                mtkView.colorPixelFormat = Formats.colorPixelFormat
                mtkView.depthStencilPixelFormat = Formats.depthPixelFormat
                mtkView.delegate = renderer

                mtkView.addGestureRecognizer(renderer.camera.panGestureRecognizer)
                mtkView.addGestureRecognizer(renderer.camera.pinchGestureRecognizer)
            }
        }
    }
}
