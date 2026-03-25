//
//  MapMetalTextureFactory.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/3/23.
//

import CoreGraphics
import Metal
import MetalKit

enum MapMetalTextureFactory {
    static func makeTexture(
        from image: CGImage?,
        device: any MTLDevice,
        label: String,
        fallbackColor: SIMD4<UInt8> = SIMD4(255, 255, 255, 255)
    ) -> (any MTLTexture)? {
        guard let image else {
            return makeFallbackTexture(device: device, label: label, color: fallbackColor)
        }

        let textureLoader = MTKTextureLoader(device: device)
        let texture = try? textureLoader.newTexture(
            cgImage: image,
            options: [
                MTKTextureLoader.Option.SRGB: false,
            ]
        )
        texture?.label = label
        return texture ?? makeFallbackTexture(device: device, label: label, color: fallbackColor)
    }

    private static func makeFallbackTexture(
        device: any MTLDevice,
        label: String,
        color: SIMD4<UInt8>
    ) -> (any MTLTexture)? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rgba8Unorm,
            width: 1,
            height: 1,
            mipmapped: false
        )
        descriptor.usage = .shaderRead

        guard let texture = device.makeTexture(descriptor: descriptor) else {
            return nil
        }

        var pixel = color
        texture.replace(
            region: MTLRegionMake2D(0, 0, 1, 1),
            mipmapLevel: 0,
            withBytes: &pixel,
            bytesPerRow: MemoryLayout<SIMD4<UInt8>>.stride
        )
        texture.label = label
        return texture
    }
}
