//
//  MetalTextureFactory.swift
//  RagnarokMetalRendering
//
//  Created by Leon Li on 2026/3/23.
//

import CoreGraphics
import Metal
import MetalKit

public enum MetalTextureFactory {
    public static func makeTexture(from image: CGImage?, device: any MTLDevice, label: String) -> (any MTLTexture)? {
        guard let image else {
            return nil
        }

        let textureLoader = MTKTextureLoader(device: device)
        let texture = try? textureLoader.newTexture(
            cgImage: image,
            options: [
                MTKTextureLoader.Option.SRGB: false,
            ]
        )
        texture?.label = label
        return texture
    }
}
