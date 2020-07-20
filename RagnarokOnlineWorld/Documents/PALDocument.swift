//
//  PALDocument.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/7/1.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation
import CoreGraphics

struct PALDocument: Document {

    var image: CGImage

    init(from stream: Stream) throws {
        let data = try stream.readToEnd()

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.noneSkipFirst.rawValue | CGImageByteOrderInfo.order32Little.rawValue
        guard let context = CGContext(
            data: nil,
            width: 128,
            height: 128,
            bitsPerComponent: 8,
            bytesPerRow: 512,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            throw DocumentError.invalidContents
        }

        let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 128)
        context.concatenate(flipVertical)

        let count = data.count / 4
        for i in 0..<count {
            let components = [
                CGFloat(data[i * 4 + 0]) / 255,
                CGFloat(data[i * 4 + 1]) / 255,
                CGFloat(data[i * 4 + 2]) / 255,
                1
            ]
            guard let color = CGColor(colorSpace: colorSpace, components: components) else {
                continue
            }

            context.setFillColor(color)

            let rect = CGRect(
                x: i % 16 * 8,
                y: i / 16 * 8,
                width: 8,
                height: 8
            )
            context.fill(rect)
        }

        guard let image = context.makeImage() else {
            throw DocumentError.invalidContents
        }

        self.image = image
    }
}
