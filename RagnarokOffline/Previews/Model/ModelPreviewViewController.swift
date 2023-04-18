//
//  ModelPreviewViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/12.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit
import MetalKit

class ModelPreviewViewController: UIViewController {

    let previewItem: PreviewItem

    private var mtkView: MTKView!
    private var renderer: ModelPreviewRenderer!

    init(previewItem: PreviewItem) {
        self.previewItem = previewItem
        super.init(nibName: nil, bundle: nil)
        title = previewItem.title
        edgesForExtendedLayout = []
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

        view.backgroundColor = .systemBackground

        loadPreviewItem()
    }

    private func loadPreviewItem() {
        DispatchQueue.global().async {
            guard case let .grf(grf, _) = self.previewItem,
                  let data = try? self.previewItem.data()
            else {
                return
            }

            let loader = DocumentLoader()
            guard let document = try? loader.load(RSMDocument.self, from: data) else {
                return
            }

            let textures = document.textures.map { textureName -> Data? in
                return grf.node(atPath: "data\\texture\\" + textureName)?.contents
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

            DispatchQueue.main.async {
                guard let renderer = try? ModelPreviewRenderer(meshes: meshes, textures: textures, boundingBox: boundingBox) else {
                    return
                }

                self.renderer = renderer

                self.mtkView.device = renderer.device
                self.mtkView.colorPixelFormat = Formats.colorPixelFormat
                self.mtkView.depthStencilPixelFormat = Formats.depthPixelFormat
                self.mtkView.delegate = renderer

                self.mtkView.addGestureRecognizer(renderer.camera.panGestureRecognizer)
                self.mtkView.addGestureRecognizer(renderer.camera.pinchGestureRecognizer)
            }
        }
    }
}
