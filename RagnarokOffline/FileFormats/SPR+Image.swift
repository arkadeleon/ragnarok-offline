//
//  SPR+Image.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/15.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import CoreGraphics
import Foundation

extension SPR {
    func image(forSpriteAt index: Int) -> StillImage? {
        let sprite = sprites[index]
        let width = Int(sprite.width)
        let height = Int(sprite.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        switch sprite.type {
        case .indexed:
            guard let palette else {
                return nil
            }

            let byteOrder = CGBitmapInfo.byteOrder32Big
            let alphaInfo = CGImageAlphaInfo.last
            let bitmapInfo = CGBitmapInfo(rawValue: byteOrder.rawValue | alphaInfo.rawValue)

            var data = sprite.data
            if version >= "2.1" {
                data = RLE().decompress(data)
            }

            let bitmapData = data
                .map { colorIndex in
                    var color = palette.colors[Int(colorIndex)]
                    color.alpha = colorIndex == 0 ? 0 : 255
                    return [color.red, color.green, color.blue, color.alpha]
                }
                .flatMap({ $0 })
            guard let provider = CGDataProvider(data: Data(bitmapData) as CFData) else {
                return nil
            }

            let image = CGImage(
                width: width,
                height: height,
                bitsPerComponent: 8,
                bitsPerPixel: 32,
                bytesPerRow: width * 4,
                space: colorSpace,
                bitmapInfo: bitmapInfo,
                provider: provider,
                decode: nil,
                shouldInterpolate: true,
                intent: .defaultIntent
            )
            return image.map(StillImage.init)
        case .rgba:
            let byteOrder = CGBitmapInfo.byteOrder32Little
            let alphaInfo = CGImageAlphaInfo.last
            let bitmapInfo = CGBitmapInfo(rawValue: byteOrder.rawValue | alphaInfo.rawValue)

            guard let provider = CGDataProvider(data: sprite.data as CFData) else {
                return nil
            }

            guard let image = CGImage(
                width: width,
                height: height,
                bitsPerComponent: 8,
                bitsPerPixel: 32,
                bytesPerRow: width * 4,
                space: colorSpace,
                bitmapInfo: bitmapInfo,
                provider: provider,
                decode: nil,
                shouldInterpolate: true,
                intent: .defaultIntent
            ) else {
                return nil
            }

            guard let context = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: colorSpace,
                bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
            ) else {
                return nil
            }

            // Flip vertically
            let transform = CGAffineTransform(1, 0, 0, -1, 0, CGFloat(height))
            context.concatenate(transform)

            context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

            let downMirroredImage = context.makeImage()
            return downMirroredImage.map(StillImage.init)
        }
    }
}
