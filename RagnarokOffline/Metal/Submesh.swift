//
//  Submesh.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/6/7.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import Metal

struct Submesh {
    let primitiveType: MTLPrimitiveType
    let indexType: MTLIndexType
    let indexBuffer: MTLBuffer
    let indexCount: Int
    let texture: MTLTexture?
}
