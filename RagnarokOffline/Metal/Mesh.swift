//
//  Mesh.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/6/7.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import Metal

struct Mesh {
    let vertexBuffers: [MTLBuffer]
    let vertexDescriptor: MTLVertexDescriptor
    let submeshes: [Submesh]
    let vertexCount: Int
}
