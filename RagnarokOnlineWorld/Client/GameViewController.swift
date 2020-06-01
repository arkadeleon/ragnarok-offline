//
//  GameViewController.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/22.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit
import MetalKit
import SGLMath

class GameViewController: UIViewController {

    private var mtkView: MTKView!
    private var renderer: Renderer!
    private var camera = Camera()

    override func loadView() {
        mtkView = MTKView()
        view = mtkView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Game"
        edgesForExtendedLayout = []

        renderer = Renderer(vertexFunctionName: "vertexShader", fragmentFunctionName: "fragmentShader", render: render)
        mtkView.device = renderer.device
        mtkView.colorPixelFormat = renderer.colorPixelFormat
        mtkView.depthStencilPixelFormat = renderer.depthStencilPixelFormat
        mtkView.delegate = renderer

        mtkView.addGestureRecognizer(camera.panGestureRecognizer)
        mtkView.addGestureRecognizer(camera.pinchGestureRecognizer)
    }

    func render(encoder: MTLRenderCommandEncoder) {
        let vertices = [
            VertexIn(position: [-0.5, -0.5, -0.5], textureCoordinate: [0.0, 0.0], normal: [0.0,  0.0, -1.0]),
            VertexIn(position: [ 0.5, -0.5, -0.5], textureCoordinate: [1.0, 0.0], normal: [0.0,  0.0, -1.0]),
            VertexIn(position: [ 0.5,  0.5, -0.5], textureCoordinate: [1.0, 1.0], normal: [0.0,  0.0, -1.0]),
            VertexIn(position: [ 0.5,  0.5, -0.5], textureCoordinate: [1.0, 1.0], normal: [0.0,  0.0, -1.0]),
            VertexIn(position: [-0.5,  0.5, -0.5], textureCoordinate: [0.0, 1.0], normal: [0.0,  0.0, -1.0]),
            VertexIn(position: [-0.5, -0.5, -0.5], textureCoordinate: [0.0, 0.0], normal: [0.0,  0.0, -1.0]),
            VertexIn(position: [-0.5, -0.5,  0.5], textureCoordinate: [0.0, 0.0], normal: [0.0,  0.0,  1.0]),
            VertexIn(position: [ 0.5, -0.5,  0.5], textureCoordinate: [1.0, 0.0], normal: [0.0,  0.0,  1.0]),
            VertexIn(position: [ 0.5,  0.5,  0.5], textureCoordinate: [1.0, 1.0], normal: [0.0,  0.0,  1.0]),
            VertexIn(position: [ 0.5,  0.5,  0.5], textureCoordinate: [1.0, 1.0], normal: [0.0,  0.0,  1.0]),
            VertexIn(position: [-0.5,  0.5,  0.5], textureCoordinate: [0.0, 1.0], normal: [0.0,  0.0,  1.0]),
            VertexIn(position: [-0.5, -0.5,  0.5], textureCoordinate: [0.0, 0.0], normal: [0.0,  0.0,  1.0]),
            VertexIn(position: [-0.5,  0.5,  0.5], textureCoordinate: [1.0, 0.0], normal: [1.0,  0.0,  0.0]),
            VertexIn(position: [-0.5,  0.5, -0.5], textureCoordinate: [1.0, 1.0], normal: [1.0,  0.0,  0.0]),
            VertexIn(position: [-0.5, -0.5, -0.5], textureCoordinate: [0.0, 1.0], normal: [1.0,  0.0,  0.0]),
            VertexIn(position: [-0.5, -0.5, -0.5], textureCoordinate: [0.0, 1.0], normal: [1.0,  0.0,  0.0]),
            VertexIn(position: [-0.5, -0.5,  0.5], textureCoordinate: [0.0, 0.0], normal: [1.0,  0.0,  0.0]),
            VertexIn(position: [-0.5,  0.5,  0.5], textureCoordinate: [1.0, 0.0], normal: [1.0,  0.0,  0.0]),
            VertexIn(position: [ 0.5,  0.5,  0.5], textureCoordinate: [1.0, 0.0], normal: [1.0,  0.0,  0.0]),
            VertexIn(position: [ 0.5,  0.5, -0.5], textureCoordinate: [1.0, 1.0], normal: [1.0,  0.0,  0.0]),
            VertexIn(position: [ 0.5, -0.5, -0.5], textureCoordinate: [0.0, 1.0], normal: [1.0,  0.0,  0.0]),
            VertexIn(position: [ 0.5, -0.5, -0.5], textureCoordinate: [0.0, 1.0], normal: [1.0,  0.0,  0.0]),
            VertexIn(position: [ 0.5, -0.5,  0.5], textureCoordinate: [0.0, 0.0], normal: [1.0,  0.0,  0.0]),
            VertexIn(position: [ 0.5,  0.5,  0.5], textureCoordinate: [1.0, 0.0], normal: [1.0,  0.0,  0.0]),
            VertexIn(position: [-0.5, -0.5, -0.5], textureCoordinate: [0.0, 1.0], normal: [0.0, -1.0,  0.0]),
            VertexIn(position: [ 0.5, -0.5, -0.5], textureCoordinate: [1.0, 1.0], normal: [0.0, -1.0,  0.0]),
            VertexIn(position: [ 0.5, -0.5,  0.5], textureCoordinate: [1.0, 0.0], normal: [0.0, -1.0,  0.0]),
            VertexIn(position: [ 0.5, -0.5,  0.5], textureCoordinate: [1.0, 0.0], normal: [0.0, -1.0,  0.0]),
            VertexIn(position: [-0.5, -0.5,  0.5], textureCoordinate: [0.0, 0.0], normal: [0.0, -1.0,  0.0]),
            VertexIn(position: [-0.5, -0.5, -0.5], textureCoordinate: [0.0, 1.0], normal: [0.0, -1.0,  0.0]),
            VertexIn(position: [-0.5,  0.5, -0.5], textureCoordinate: [0.0, 1.0], normal: [0.0,  1.0,  0.0]),
            VertexIn(position: [ 0.5,  0.5, -0.5], textureCoordinate: [1.0, 1.0], normal: [0.0,  1.0,  0.0]),
            VertexIn(position: [ 0.5,  0.5,  0.5], textureCoordinate: [1.0, 0.0], normal: [0.0,  1.0,  0.0]),
            VertexIn(position: [ 0.5,  0.5,  0.5], textureCoordinate: [1.0, 0.0], normal: [0.0,  1.0,  0.0]),
            VertexIn(position: [-0.5,  0.5,  0.5], textureCoordinate: [0.0, 0.0], normal: [0.0,  1.0,  0.0]),
            VertexIn(position: [-0.5,  0.5, -0.5], textureCoordinate: [0.0, 1.0], normal: [0.0,  1.0,  0.0])
        ]
        let vertexBuffer = encoder.device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<VertexIn>.stride, options: [])!
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

        let time = Float(CACurrentMediaTime())

        let model = SGLMath.rotate(Matrix4x4<Float>(), time, [0.5, 1, 0])

        let normal = Matrix3x3(model.inverse.transpose)

        let view: Matrix4x4<Float> = SGLMath.lookAt(camera.position, camera.position + camera.front, camera.up)

        let projection = SGLMath.perspective(radians(camera.zoom), Float(mtkView.bounds.width / mtkView.bounds.height), 0.1, 100)

        var uniforms = VertexUniforms(
            model: unsafeBitCast(model, to: float4x4.self),
            normal: float3x3([normal[0][0], normal[0][1], normal[0][2]], [normal[1][0], normal[1][1], normal[1][2]], [normal[2][0], normal[2][1], normal[2][2]]),
            view: unsafeBitCast(view, to: float4x4.self),
            projection: unsafeBitCast(projection, to: float4x4.self)
        )
        let uniformsBuffer = encoder.device.makeBuffer(bytes: &uniforms, length: MemoryLayout<VertexUniforms>.stride, options: [])!
        encoder.setVertexBuffer(uniformsBuffer, offset: 0, index: 1)

        var fragmentUniforms = FragmentUniforms(
            lightPosition: [0, 5, 0]
        )
        let fragmentUniformsBuffer = encoder.device.makeBuffer(bytes: &fragmentUniforms, length: MemoryLayout<FragmentUniforms>.stride, options: [])!
        encoder.setFragmentBuffer(fragmentUniformsBuffer, offset: 0, index: 0)

        let textureLoaader = MTKTextureLoader(device: encoder.device)
        let image = UIImage(named: "wall.jpg")!
        let texture = try! textureLoaader.newTexture(cgImage: image.cgImage!, options: nil)
        encoder.setFragmentTexture(texture, index: 0)

        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
    }
}
