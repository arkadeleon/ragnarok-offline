//
//  Mesh.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/6/7.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import Metal

public struct Mesh {
    public let vertexBuffers: [MTLBuffer]
    public let vertexDescriptor: MTLVertexDescriptor
    public let submeshes: [Submesh]
    public let vertexCount: Int

    public init(vertexBuffers: [MTLBuffer], vertexDescriptor: MTLVertexDescriptor, submeshes: [Submesh], vertexCount: Int) {
        self.vertexBuffers = vertexBuffers
        self.vertexDescriptor = vertexDescriptor
        self.submeshes = submeshes
        self.vertexCount = vertexCount
    }
}
