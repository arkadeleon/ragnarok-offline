//
//  SPR+Image.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/15.
//

import CoreGraphics
import Foundation
import ImageRendering

extension SPR {
    public func imagesBySpriteType(palette: PAL? = nil) -> [SPR.SpriteType : [CGImage?]] {
        var indexedImages = [CGImage?]()
        var rgbaImages = [CGImage?]()

        for (index, sprite) in sprites.enumerated() {
            let image = imageForSprite(at: index, palette: palette)
            switch sprite.type {
            case .indexed:
                indexedImages.append(image)
            case .rgba:
                rgbaImages.append(image)
            }
        }

        var imagesBySpriteType = [SPR.SpriteType : [CGImage?]]()
        imagesBySpriteType[.indexed] = indexedImages
        imagesBySpriteType[.rgba] = rgbaImages

        return imagesBySpriteType
    }

    public func imageForSprite(at index: Int, palette: PAL? = nil) -> CGImage? {
        guard 0..<sprites.count ~= index else {
            return nil
        }

        let sprite = sprites[index]
        let width = Int(sprite.width)
        let height = Int(sprite.height)
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!

        switch sprite.type {
        case .indexed:
            guard let palette = palette ?? self.palette else {
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
            return image
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

            let renderer = CGImageRenderer(size: CGSize(width: width, height: height), flipped: true)
            let downMirroredImage = renderer.image { cgContext in
                cgContext.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
            }
            return downMirroredImage
        }
    }
}
