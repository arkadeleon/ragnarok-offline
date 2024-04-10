//
//  Submesh.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/6/7.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import Metal

public struct Submesh {
    public let primitiveType: MTLPrimitiveType
    public let indexType: MTLIndexType
    public let indexBuffer: MTLBuffer
    public let indexCount: Int
    public let texture: MTLTexture?

    public init(primitiveType: MTLPrimitiveType, indexType: MTLIndexType, indexBuffer: MTLBuffer, indexCount: Int, texture: MTLTexture?) {
        self.primitiveType = primitiveType
        self.indexType = indexType
        self.indexBuffer = indexBuffer
        self.indexCount = indexCount
        self.texture = texture
    }
}
