//
//  RSMDocumentViewController.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/12.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit
import MetalKit
import SGLMath

class RSMDocumentViewController: UIViewController {

    let document: RSMDocument
    private var model: Model?

    private var mtkView: MTKView!
    private var renderer: Renderer!
    private var camera = Camera()

    init(document: RSMDocument) {
        self.document = document
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

        title = document.name
        edgesForExtendedLayout = []

        let infoItem = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(infoItemAction(_:)))
        navigationItem.rightBarButtonItem = infoItem

        view.backgroundColor = .systemBackground

        renderer = Renderer(vertexFunctionName: "modelVertexShader", fragmentFunctionName: "modelFragmentShader", render: render)
        mtkView.device = renderer.device
        mtkView.colorPixelFormat = renderer.colorPixelFormat
        mtkView.depthStencilPixelFormat = renderer.depthStencilPixelFormat
        mtkView.delegate = renderer

        mtkView.addGestureRecognizer(camera.panGestureRecognizer)
        mtkView.addGestureRecognizer(camera.pinchGestureRecognizer)

        document.open { result in
            defer {
                self.document.close()
            }

            guard case .entryInArchive(let archive, _) = self.document.source else {
                return
            }

            guard case .success(let contents) = result else {
                return
            }

            let textureLoader = TextureLoader(device: self.renderer.device)
            let textures = contents.textures.map { textureName -> MTLTexture? in
                guard let entry = archive.entry(forName: "data\\texture\\" + textureName) else {
                    return nil
                }
                guard let contents = try? archive.contents(of: entry) else {
                    return nil
                }
                return textureLoader.newTexture(data: contents)
            }

            let (boundingBox, wrappers) = contents.calcBoundingBox()

            let model = RSMModel(
                position: [0, 0, 0],
                rotation: [0, 0, 0],
                scale: [-0.075, -0.075, -0.075],
                filename: ""
            )
            let instance = contents.createInstance(model: model, width: 0, height: 0)

            let meshes = contents.compile(instances: [instance], wrappers: wrappers, boundingBox: boundingBox)

            self.model = Model(meshes: meshes, textures: textures, boundingBox: boundingBox)
        }
    }

    @objc private func infoItemAction(_ sender: Any) {
        let infoViewController = RSMDocumentInfoViewController(document: document)
        let navigationController = UINavigationController(rootViewController: infoViewController)
        present(navigationController, animated: true, completion: nil)
    }

    private func render(encoder: MTLRenderCommandEncoder) {
        guard let model = model else {
            return
        }

        let time = CACurrentMediaTime()

        var modelviewMatrix = Matrix4x4<Float>()
        modelviewMatrix = SGLMath.translate(modelviewMatrix, [0, -model.boundingBox.range[1] * 0.1, -model.boundingBox.range[1] * 0.5 - 5])
        modelviewMatrix = SGLMath.rotate(modelviewMatrix, radians(15), [1, 0, 0])
        modelviewMatrix = SGLMath.rotate(modelviewMatrix, Float(radians(time * 360 / 8)), [0, 1, 0])

        let projectionMatrix = SGLMath.perspective(radians(camera.zoom), Float(mtkView.bounds.width / mtkView.bounds.height), 1, 1000)

        let normalMatrix = Matrix3x3(modelviewMatrix).inverse.transpose

        let fog = Fog(
            use: false,
            exist: true,
            far: 30,
            near: 80,
            factor: 1,
            color: [1, 1, 1]
        )

        let light = Light(
            opacity: 1,
            ambient: [1, 1, 1],
            diffuse: [0, 0, 0],
            direction: [0, 1, 0]
        )

        model.render(
            encoder: encoder,
            modelviewMatrix: modelviewMatrix,
            projectionMatrix: projectionMatrix,
            normalMatrix: normalMatrix,
            fog: fog,
            light: light
        )
    }
}
