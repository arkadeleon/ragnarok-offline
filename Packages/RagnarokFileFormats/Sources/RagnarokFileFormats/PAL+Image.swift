//
//  PAL+Image.swift
//  RagnarokFileFormats
//
//  Created by Leon Li on 2023/12/7.
//

import CoreGraphics

extension PAL {
    public func image(at size: CGSize) -> CGImage? {
        let width = Int(size.width)
        let height = Int(size.height)
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let bitmapInfo = CGBitmapInfo.byteOrderDefault.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue

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

        // Flip vertically
        let transform = CGAffineTransform(1, 0, 0, -1, 0, CGFloat(height))
        context.concatenate(transform)

        let blockSize = CGSizeMake(size.width / 16, size.height / 16)
        for x in 0..<16 {
            for y in 0..<16 {
                let color = cgColor(for: colors[y * 16 + x])
                context.setFillColor(color)

                let rect = CGRect(
                    x: CGFloat(x) * blockSize.width,
                    y: CGFloat(y) * blockSize.height,
                    width: blockSize.width,
                    height: blockSize.height
                )
                context.fill(rect)
            }
        }

        let image = context.makeImage()
        return image
    }

    func cgColor(for color: RGBAColor) -> CGColor {
        var red = color.red
        var green = color.green
        var blue = color.blue
        var alpha = color.alpha

        // Reference: https://github.com/rdw-archive/RagnarokFileFormats/blob/master/PAL.MD
        if red >= 0xFE && green < 0x04 && blue >= 0xFE {
            red = 10
            green = 10
            blue = 10
            alpha = 0
        } else {
            alpha = 255
        }

        let color = CGColor(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: CGFloat(alpha) / 255
        )
        return color
    }
}
