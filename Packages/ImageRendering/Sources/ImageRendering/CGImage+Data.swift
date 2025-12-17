//
//  CGImage+Data.swift
//  ImageRendering
//
//  Created by Leon Li on 2024/2/23.
//

import Accelerate
import AVFoundation
import CoreGraphics
import ImageIO

public func CGImageCreateWithData(_ data: Data) -> CGImage? {
    guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
        return nil
    }

    guard let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
        return nil
    }

    return image
}

extension CGImage {
    public func resizing(_ size: CGSize) -> CGImage? {
        let availableRect = AVMakeRect(
            aspectRatio: CGSize(width: width, height: height),
            insideRect: CGRect(origin: .zero, size: size)
        )
        let targetSize = availableRect.size

        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue | CGImageByteOrderInfo.order32Little.rawValue

        guard let context = CGContext(
            data: nil,
            width: Int(targetSize.width),
            height: Int(targetSize.height),
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }

        let rect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        context.draw(self, in: rect)

        let image = context.makeImage()
        return image
    }
}

extension CGImage {
    public func removingMagentaPixels() -> CGImage? {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
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
        context.draw(self, in: rect)

        let pixelCount = width * height
        guard let pixels = context.data?.bindMemory(to: Pixel_8888.self, capacity: pixelCount) else {
            return nil
        }

        // Remove magenta pixels.
        for i in 0..<pixelCount {
            if pixels[i].0 > 230 && pixels[i].1 < 20 && pixels[i].2 > 230 {
                pixels[i].0 = 0
                pixels[i].1 = 0
                pixels[i].2 = 0
                pixels[i].3 = 0
            }
        }

        let image = context.makeImage()
        return image
    }
}
