//
//  MDLTexture+Data.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/9/2.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import ModelIO
import ImageIO

extension MDLTexture {

    convenience init?(name: String, data: Data) {
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
              let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            return nil
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGImageByteOrderInfo.order32Big.rawValue

        guard let context = CGContext(
            data: nil,
            width: image.width,
            height: image.height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }

        let rect = CGRect(x: 0, y: 0, width: image.width, height: image.height)
        context.draw(image, in: rect)

        let pixelDataCount = context.bytesPerRow * image.height
        guard var pixelData = context.data.flatMap({ Data(bytes: $0, count: pixelDataCount) }) else {
            return nil
        }

        // Remove magenta pixels
        for y in 0..<image.height {
            for x in 0..<image.width {
                let base = y * context.bytesPerRow + x * 4
                let red = pixelData[base + 0]
                let green = pixelData[base + 1]
                let blue = pixelData[base + 2]
                if red > 230 && green < 20 && blue > 230 {
                    pixelData[base + 0] = 0
                    pixelData[base + 1] = 0
                    pixelData[base + 2] = 0
                    pixelData[base + 3] = 0
                }
            }
        }

        self.init(
            data: pixelData,
            topLeftOrigin: false,
            name: name,
            dimensions: [Int32(image.width), Int32(image.height)],
            rowStride: context.bytesPerRow,
            channelCount: 4,
            channelEncoding: .uint8,
            isCube: false
        )
    }
}
