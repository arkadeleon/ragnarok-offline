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
        let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue | CGImageByteOrderInfo.order32Little.rawValue

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

        guard let pixelData = context.data else {
            return nil
        }

        self.init(
            data: Data(bytes: pixelData, count: context.bytesPerRow * image.height),
            topLeftOrigin: true,
            name: name,
            dimensions: [Int32(image.width), Int32(image.height)],
            rowStride: context.bytesPerRow,
            channelCount: 4,
            channelEncoding: .uint8,
            isCube: false
        )
    }
}
