//
//  GameScene.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/6/7.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import Metal
import MetalKit

struct GameScene {
    let device: MTLDevice

    lazy var models: [Model3D] = {
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
        let vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<VertexIn>.stride)!

        let indices: [UInt16] = (0..<vertices.count).map({ UInt16($0) })
        let indexBuffer = device.makeBuffer(bytes: indices, length: MemoryLayout<UInt16>.size * indices.count)!

        let textureLoader = MTKTextureLoader(device: device)
        let image = UIImage(named: "wall.jpg")!
        let texture = try! textureLoader.newTexture(cgImage: image.cgImage!, options: nil)

        let submesh = Submesh(
            primitiveType: .triangle,
            indexType: .uint16,
            indexBuffer: indexBuffer,
            indexBufferOffset: 0,
            indexCount: indices.count,
            texture: texture
        )

        let mesh = Mesh(
            vertexBuffers: [vertexBuffer],
            vertexDescriptor: MTLVertexDescriptor(),
            submeshes: [submesh],
            vertexCount: vertices.count
        )

        let model = Model3D(meshes: [mesh])

        return [model]
    }()

    var camera = ArcballCamera()
}
