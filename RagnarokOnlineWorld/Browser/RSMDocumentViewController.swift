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
    private var textures: [MTLTexture?] = []
    private var vertices: [[[ModelVertex]]] = []

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

        document.open { _ in
            switch self.document.source {
            case .url(_):
                break
            case .entryInArchive(let archive, _):
                let textureLoader = TextureLoader(device: self.renderer.device)
                self.textures = self.document.textures.map { textureName -> MTLTexture? in
                    guard let entry = archive.entry(forName: "data\\texture\\" + textureName) else {
                        return nil
                    }
                    guard let contents = try? archive.contents(of: entry) else {
                        return nil
                    }
                    return textureLoader.newTexture(data: contents)
                }

                let model = RSMModel(
                    position: [0, 0, 0],
                    rotation: [0, 0, 0],
                    scale: [-0.075, -0.075, -0.075],
                    filename: "")
                self.document.createInstance(model: model, width: 0, height: 0)

                self.vertices = self.document.compile()
            }
            self.document.close()
        }
    }

    @objc private func infoItemAction(_ sender: Any) {
        let infoViewController = RSMDocumentInfoViewController(document: document)
        let navigationController = UINavigationController(rootViewController: infoViewController)
        present(navigationController, animated: true, completion: nil)
    }

    private func render(encoder: MTLRenderCommandEncoder) {
        let time = CACurrentMediaTime()

        var modelView = Matrix4x4<Float>()
        modelView = SGLMath.translate(modelView, [0, -document.box.range[1]*0.1, -document.box.range[1]*0.5-5])
        modelView = SGLMath.rotate(modelView, radians(15), [1, 0, 0])
        modelView = SGLMath.rotate(modelView, Float(radians(time * 360 / 8)), [0, 1, 0])

        let normal = Matrix3x3(modelView).inverse.transpose

        let projection = SGLMath.perspective(radians(camera.zoom), Float(mtkView.bounds.width / mtkView.bounds.height), 1, 1000)

        var uniforms = ModelVertexUniforms(
            modelViewMat: modelView.simd,
            projectionMat: projection.simd,
            lightDirection: [0, 1, 0],
            normalMat: normal.simd
        )
        let uniformsBuffer = encoder.device.makeBuffer(bytes: &uniforms, length: MemoryLayout<ModelVertexUniforms>.stride, options: [])!
        encoder.setVertexBuffer(uniformsBuffer, offset: 0, index: 1)

        var fragmentUniforms = ModelFragmentUniforms(
            fogUse: 0,
            fogNear: 180,
            fogFar: 30,
            fogColor: [1, 1, 1],
            lightAmbient: [1, 1, 1],
            lightDiffuse: [0, 0, 0],
            lightOpacity: 1
        )
        let fragmentUniformsBuffer = encoder.device.makeBuffer(bytes: &fragmentUniforms, length: MemoryLayout<ModelFragmentUniforms>.stride, options: [])!
        encoder.setFragmentBuffer(fragmentUniformsBuffer, offset: 0, index: 0)

        for v1s in vertices {
            for (i, vs) in v1s.enumerated() where vs.count > 0 {
                let vertexBuffer = encoder.device.makeBuffer(bytes: vs, length: vs.count * MemoryLayout<ModelVertex>.stride, options: [])!
                encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)



                let texture = textures[i]
                encoder.setFragmentTexture(texture, index: 0)

                encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vs.count)

            }
        }
    }
}
