//
//  Palette.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/7/1.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import CoreGraphics

struct Palette: Encodable {
    var colors: [Color] = []

    init(data: Data) throws {
        let stream = MemoryStream(data: data)
        let reader = BinaryReader(stream: stream)

        defer {
            reader.close()
        }

        for _ in 0..<256 {
            let color = try Color(from: reader)
            colors.append(color)
        }
    }
}

extension Palette {
    struct Color: Encodable {
        var red: UInt8
        var green: UInt8
        var blue: UInt8
        var alpha: UInt8

        init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
            self.red = red
            self.green = green
            self.blue = blue
            self.alpha = alpha
        }

        init(from reader: BinaryReader) throws {
            red = try reader.readInt()
            green = try reader.readInt()
            blue = try reader.readInt()
            alpha = try reader.readInt()
        }
    }
}

extension Palette {
    func image(at size: CGSize) -> CGImage? {
        let width = Int(size.width)
        let height = Int(size.height)
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo.byteOrderDefault.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }

        // Flip vertically
        let transform = CGAffineTransform(1, 0, 0, -1, 0, CGFloat(height))
        context.concatenate(transform)

        let blockSize = CGSizeMake(size.width / 16, size.height / 16)
        for x in 0..<16 {
            for y in 0..<16 {
                let color = colors[y * 16 + x].cgColor()
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
}

extension Palette.Color {
    func cgColor() -> CGColor {
        var red = red
        var green = green
        var blue = blue
        var alpha = alpha

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