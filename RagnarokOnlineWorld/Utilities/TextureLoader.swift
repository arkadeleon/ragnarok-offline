//
//  TextureLoader.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/6/16.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import MetalKit
import Accelerate

class TextureLoader: NSObject {

    private let underlyingLoader: MTKTextureLoader

    init(device: MTLDevice) {
        underlyingLoader = MTKTextureLoader(device: device)
        super.init()
    }

    func newTexture(data: Data) -> MTLTexture? {
        guard let image = UIImage(data: data), let cgImage = image.cgImage else {
            return nil
        }

        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue | CGImageByteOrderInfo.order32Little.rawValue

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }

        let rect = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
        context.draw(cgImage, in: rect)

        let pixelCount = width * height
        guard let pixels = context.data?.bindMemory(to: Pixel_8888.self, capacity: pixelCount) else {
            return nil
        }

        // Remove magenta pixels
        for i in 0..<pixelCount {
            if pixels[i].0 > 230 && pixels[i].1 < 20 && pixels[i].2 > 230 {
                pixels[i].0 = 0
                pixels[i].1 = 0
                pixels[i].2 = 0
                pixels[i].3 = 0
            }
        }

        guard let decompressedImage = context.makeImage() else {
            return nil
        }

        let texture = try? underlyingLoader.newTexture(cgImage: decompressedImage, options: nil)
        return texture
    }
}
