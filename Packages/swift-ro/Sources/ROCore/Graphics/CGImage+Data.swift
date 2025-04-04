//
//  CGImage+Data.swift
//  RagnarokOffline
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

    let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
    return image
}

extension CGImage {
    public func resizing(_ size: CGSize) -> CGImage? {
        let availableRect = AVMakeRect(
            aspectRatio: CGSize(width: width, height: height),
            insideRect: CGRect(origin: .zero, size: size)
        )
        let targetSize = availableRect.size

        let colorSpace = CGColorSpaceCreateDeviceRGB()
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

extension CGImage {
    public func applyingColor(_ color: RGBAColor) -> CGImage? {
        if color == RGBAColor(red: 255, green: 255, blue: 255, alpha: 255) {
            return self
        }

        // Presume the format is RGBA8888
        guard let format = vImage_CGImageFormat(cgImage: self) else {
            return nil
        }

        guard var src = try? vImage_Buffer(cgImage: self) else {
            return nil
        }

        defer {
            src.free()
        }

        guard var dest = try? vImage_Buffer(width: width, height: height, bitsPerPixel: UInt32(bitsPerPixel)) else {
            return nil
        }

        defer {
            dest.free()
        }

        let r = UInt16(color.red)
        let g = UInt16(color.green)
        let b = UInt16(color.blue)
        let a = UInt16(color.alpha)
        let matrix: [UInt16] = [
            r, 0, 0, 0,
            0, g, 0, 0,
            0, 0, b, 0,
            0, 0, 0, a,
        ]

        let divisor: Int32 = 256

        let error = vImageMatrixMultiply_ARGB8888(&src, &dest, matrix, divisor, nil, nil, 0)
        guard error == kvImageNoError else {
            return nil
        }

        let image = try? dest.createCGImage(format: format)
        return image
    }
}
