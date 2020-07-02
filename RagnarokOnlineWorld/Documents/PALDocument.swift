//
//  PALDocument.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/7/1.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation
import CoreGraphics

class PALDocument: Document {

    let source: DocumentSource

    required init(source: DocumentSource) {
        self.source = source
    }

    func load(from data: Data) -> Result<CGImage, DocumentError> {
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
            return .failure(.invalidContents)
        }

        let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 128)
        context.concatenate(flipVertical)

        let count = data.count / 4
        for i in 0..<count {
            let color = CGColor(
                red: CGFloat(data[i * 4 + 0]) / 255,
                green: CGFloat(data[i * 4 + 1]) / 255,
                blue: CGFloat(data[i * 4 + 2]) / 255,
                alpha: 1
            )
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
            return .failure(.invalidContents)
        }

        return .success(image)
    }
}
