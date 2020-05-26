//
//  GameViewController.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/22.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit
import MetalKit

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
                VertexIn(position: [0, 1], color: [1, 0, 0, 1]),
                VertexIn(position: [-1, -1], color: [0, 1, 0, 1]),
                VertexIn(position: [1, -1], color: [0, 0, 1, 1])
            ]
            let vertexBuffer = encoder.device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<VertexIn>.stride, options: [])!
            encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
        }
        mtkView.device = renderer.device
        mtkView.colorPixelFormat = renderer.colorPixelFormat
        mtkView.delegate = renderer
    }
}
