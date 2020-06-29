//
//  GNDDocumentViewController.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/6/23.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit
import MetalKit
import SGLMath

class GNDDocumentViewController: UIViewController {

    let document: GNDDocument
    private var textures: [MTLTexture?] = []
    private var vertices: [GroundVertex] = []

    private var mtkView: MTKView!
    private var renderer: Renderer!
    private var camera = Camera()

    init(document: GNDDocument) {
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

        renderer = Renderer(vertexFunctionName: "groundVertexShader", fragmentFunctionName: "groundFragmentShader", render: render)
        mtkView.device = renderer.device
        mtkView.colorPixelFormat = renderer.colorPixelFormat
        mtkView.depthStencilPixelFormat = renderer.depthStencilPixelFormat
        mtkView.delegate = renderer

        mtkView.addGestureRecognizer(camera.panGestureRecognizer)
        mtkView.addGestureRecognizer(camera.pinchGestureRecognizer)

        document.open { _ in
            self.vertices = self.document.compile(WATER_LEVEL: 1, WATER_HEIGHT: 1).mesh
            self.document.close()
        }
    }

    @objc private func infoItemAction(_ sender: Any) {
//        let infoViewController = RSMDocumentInfoViewController(document: document)
//        let navigationController = UINavigationController(rootViewController: infoViewController)
//        present(navigationController, animated: true, completion: nil)
    }

    private func render(encoder: MTLRenderCommandEncoder) {

        let projection = SGLMath.perspective(radians(camera.zoom), Float(mtkView.bounds.width / mtkView.bounds.height), 1, 1000)

        var uniforms = GroundVertexUniforms(
            modelViewMat: matrix_identity_float4x4,
            projectionMat: unsafeBitCast(projection, to: float4x4.self),
            lightDirection: [0.0, 0.0, 0.0],
            normalMat: matrix_identity_float3x3
        )
        let uniformsBuffer = encoder.device.makeBuffer(bytes: &uniforms, length: MemoryLayout<GroundVertexUniforms>.stride, options: [])!
        encoder.setVertexBuffer(uniformsBuffer, offset: 0, index: 1)

        var fragmentUniforms = GroundFragmentUniforms()
        let fragmentUniformsBuffer = encoder.device.makeBuffer(bytes: &fragmentUniforms, length: MemoryLayout<GroundFragmentUniforms>.stride, options: [])!
        encoder.setFragmentBuffer(fragmentUniformsBuffer, offset: 0, index: 0)

        let vertices = self.vertices
        if vertices.count > 0 {
            let vertexBuffer = encoder.device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<GroundVertex>.stride, options: [])!
            encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)



    //        let texture = textures[i]
    //        encoder.setFragmentTexture(texture, index: 0)

            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
        }
    }
}
