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
    private var textures: [MTLTexture] = []
    private var vectices: [[[RSMVertexIn]]] = []

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

        view.backgroundColor = .systemBackground

        renderer = Renderer(vertexFunctionName: "rsmVertexShader", fragmentFunctionName: "rsmFragmentShader", render: render)
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
                let textureLoader = MTKTextureLoader(device: self.renderer.device)
                for textureName in self.document.textures {
                    guard let entry = archive.entry(forPath: "data\\texture\\" + textureName) else {
                        continue
                    }
                    guard let contents = try? archive.contents(of: entry) else {
                        continue
                    }
                    guard let image = UIImage(data: contents), let cgImage = image.cgImage else {
                        continue
                    }
                    do {
                        let context = CGContext(
                            data: nil,
                            width: Int(image.size.width),
                            height: Int(image.size.height),
                            bitsPerComponent: 8,
                            bytesPerRow: Int(image.size.width) * 4,
                            space: CGColorSpaceCreateDeviceRGB(),
                            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGImageByteOrderInfo.order32Little.rawValue
                        )!
                        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
                        let data = context.data!.bindMemory(to: UInt8.self, capacity: Int(image.size.width) * Int(image.size.height) * 4)
                        for i in 0..<(Int(image.size.width) * Int(image.size.height)) {
                            if data[i * 4 + 0] > 230 && data[i * 4 + 1] < 20 && data[i * 4 + 2] > 230 {
                                data[i * 4 + 0] = 0
                                data[i * 4 + 1] = 0
                                data[i * 4 + 2] = 0
                                data[i * 4 + 3] = 0
                            }
                        }
                        let cg = context.makeImage()
                        let texture = try textureLoader.newTexture(cgImage: cg!, options: nil)
                        self.textures.append(texture)
                    } catch let error {
                        print(error)
                    }
//                    guard let texture = try? textureLoader.newTexture(cgImage: cgImage, options: nil) else {
//                        continue
//                    }
                }

                let model = RSMModel(
                    position: [0, 0, 0],
                    rotation: [0, 0, 0],
                    scale: [-0.075, -0.075, -0.075],
                    filename: "")
                self.document.createInstance(model: model, width: 0, height: 0)

                let meshes = self.document.compile()
                self.vectices = meshes.map({ (x) -> [[RSMVertexIn]] in
                    return x.map { (y) -> [RSMVertexIn] in
                        let count = y.count / 9
                        var vs = [RSMVertexIn]()
                        for i in 0..<count {
                            let v = RSMVertexIn(
                                position: [y[i * 9 + 0], y[i * 9 + 1], y[i * 9 + 2]],
                                normal: [y[i * 9 + 3], y[i * 9 + 4], y[i * 9 + 5]],
                                textureCoordinate: [y[i * 9 + 6], y[i * 9 + 7]],
                                alpha: y[i * 9 + 8]
                            )
                            vs.append(v)
                        }
                        return vs
                    }
                })
            }
            self.document.close()
        }
    }

    func render(encoder: MTLRenderCommandEncoder) {
        let time = Float(CACurrentMediaTime())

        var modelView = Matrix4x4<Float>()
        modelView = SGLMath.translate(modelView, [0, -document.box.range[1]*0.1, -document.box.range[1]*0.5-5])
        modelView = SGLMath.rotate(modelView, radians(15), [1, 0, 0])
        modelView = SGLMath.rotate(modelView, time, [0, 1, 0])

        let normal = Matrix3x3(modelView).inverse.transpose

        let projection = SGLMath.perspective(radians(camera.zoom), Float(mtkView.bounds.width / mtkView.bounds.height), 1, 1000)

        var uniforms = RSMVertexUniforms(
            modelViewMat: unsafeBitCast(modelView, to: float4x4.self),
            projectionMat: unsafeBitCast(projection, to: float4x4.self),
            lightDirection: [0, 1, 0],
            normalMat: float3x3([normal[0][0], normal[0][1], normal[0][2]], [normal[1][0], normal[1][1], normal[1][2]], [normal[2][0], normal[2][1], normal[2][2]])
        )
        let uniformsBuffer = encoder.device.makeBuffer(bytes: &uniforms, length: MemoryLayout<RSMVertexUniforms>.stride, options: [])!
        encoder.setVertexBuffer(uniformsBuffer, offset: 0, index: 1)

        var fragmentUniforms = RSMFragmentUniforms(
            fogUse: 0,
            fogNear: 180,
            fogFar: 30,
            fogColor: [1, 1, 1],
            lightAmbient: [1, 1, 1],
            lightDiffuse: [0, 0, 0],
            lightOpacity: 1
        )
        let fragmentUniformsBuffer = encoder.device.makeBuffer(bytes: &fragmentUniforms, length: MemoryLayout<RSMFragmentUniforms>.stride, options: [])!
        encoder.setFragmentBuffer(fragmentUniformsBuffer, offset: 0, index: 0)

        for v1s in vectices {
            for (i, vs) in v1s.enumerated() {
                let vertexBuffer = encoder.device.makeBuffer(bytes: vs, length: vs.count * MemoryLayout<RSMVertexIn>.stride, options: [])!
                encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)



                let texture = textures[i]
                encoder.setFragmentTexture(texture, index: 0)

                encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vs.count)

            }
        }
    }
}
