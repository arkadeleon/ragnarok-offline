//
//  CGImage+Decode.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/7/6.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import CoreGraphics

extension CGImage {

    var decoded: CGImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue | CGImageByteOrderInfo.order32Little.rawValue

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }

        let rect = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
        context.draw(self, in: rect)

        return context.makeImage()
    }
}
