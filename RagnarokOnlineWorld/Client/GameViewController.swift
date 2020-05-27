//
//  GameViewController.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/22.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit
import GLKit
import MetalKit

struct VertexUniforms {
    var transform: GLKMatrix4
}

class GameViewController: UIViewController {

    private var mtkView: MTKView!
    private var renderer: Renderer!

    override func loadView() {
        mtkView = MTKView()
        view = mtkView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Game"
        edgesForExtendedLayout = []

        renderer = Renderer(vertexFunctionName: "vertexShader", fragmentFunctionName: "fragmentShader") { encoder in
            let vertices = [
                VertexIn(position: [0, 1], textureCoordinate: [4, 0]),
                VertexIn(position: [-1, -1], textureCoordinate: [0, 1]),
                VertexIn(position: [1, -1], textureCoordinate: [0, 0])
            ]
            let vertexBuffer = encoder.device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<VertexIn>.stride, options: [])!
            encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

            var uniforms = VertexUniforms(
                transform: GLKMatrix4RotateX(GLKMatrix4Identity, Float.pi)
            )
            let uniformsBuffer = encoder.device.makeBuffer(bytes: &uniforms, length: MemoryLayout<VertexUniforms>.stride, options: [])!
            encoder.setVertexBuffer(uniformsBuffer, offset: 0, index: 1);

            let textureLoaader = MTKTextureLoader(device: encoder.device)
            let image = UIImage(named: "wall.jpg")!
            let texture = try! textureLoaader.newTexture(cgImage: image.cgImage!, options: nil)
            encoder.setFragmentTexture(texture, index: 0)

            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
        }
        mtkView.device = renderer.device
        mtkView.colorPixelFormat = renderer.colorPixelFormat
        mtkView.delegate = renderer
    }
}
