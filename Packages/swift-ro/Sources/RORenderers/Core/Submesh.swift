//
//  Submesh.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/6/7.
//

import Metal

public struct Submesh {
    public let primitiveType: MTLPrimitiveType
    public let indexType: MTLIndexType
    public let indexBuffer: any MTLBuffer
    public let indexCount: Int
    public let texture: (any MTLTexture)?

    public init(primitiveType: MTLPrimitiveType, indexType: MTLIndexType, indexBuffer: any MTLBuffer, indexCount: Int, texture: (any MTLTexture)?) {
        self.primitiveType = primitiveType
        self.indexType = indexType
        self.indexBuffer = indexBuffer
        self.indexCount = indexCount
        self.texture = texture
    }
}
