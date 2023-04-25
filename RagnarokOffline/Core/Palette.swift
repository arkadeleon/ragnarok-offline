//
//  Palette.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/7/1.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit

struct Palette {

    struct Color {
        var red: UInt8
        var green: UInt8
        var blue: UInt8
        var alpha: UInt8
    }

    var colors: [Color]

    init(data: Data) throws {
        var buffer = ByteBuffer(data: data)

        colors = try (0..<256).map { _ in
            try buffer.readPaletteColor()
        }
    }
}

extension Palette {

    func image(at size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let blockSize = CGSizeMake(size.width / 16, size.height / 16)

        let image = renderer.image { context in
            for x in 0..<16 {
                for y in 0..<16 {
                    let color = colors[y * 16 + x]
                    let uiColor = UIColor(paletteColor: color)
                    uiColor.setFill()

                    let rect = CGRect(
                        x: CGFloat(x) * blockSize.width,
                        y: CGFloat(y) * blockSize.height,
                        width: blockSize.width,
                        height: blockSize.height
                    )
                    context.fill(rect)
                }
            }
        }
        return image
    }
}

extension ByteBuffer {

    @inlinable
    mutating func readPaletteColor() throws -> Palette.Color {
        let red = try readUInt8()
        let green = try readUInt8()
        let blue = try readUInt8()
        let alpha = try readUInt8()
        let color = Palette.Color(
            red: red,
            green: green,
            blue: blue,
            alpha: alpha
        )
        return color
    }
}

extension UIColor {

    convenience init(paletteColor: Palette.Color) {
        var red = paletteColor.red
        var green = paletteColor.green
        var blue = paletteColor.blue
        var alpha = paletteColor.alpha

        // Reference: https://github.com/rdw-archive/RagnarokFileFormats/blob/master/PAL.MD
        if red >= 0xFE && green < 0x04 && blue >= 0xFE {
            red = 10
            green = 10
            blue = 10
            alpha = 0
        } else {
            alpha = 255
        }

        self.init(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: CGFloat(alpha) / 255
        )
    }
}
