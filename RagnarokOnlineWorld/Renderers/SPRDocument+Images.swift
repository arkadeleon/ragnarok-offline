//
//  SPRDocument+Images.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/7/1.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import CoreGraphics

extension SPRDocument.Contents {

    func images() -> [CGImage] {
        var images: [CGImage] = []

        for frame in frames {
            let width = Int(frame.width)
            let height = Int(frame.height)
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGImageByteOrderInfo.order32Big.rawValue

            guard let context = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: colorSpace,
                bitmapInfo: bitmapInfo
            ) else {
                continue
            }

            guard let data = context.data?.bindMemory(to: UInt8.self, capacity: width * height * 4) else {
                continue
            }

            switch frame.type {
            case .pal:
                for y in 0..<height {
                    for x in 0..<width {
                        let i = Int(frame.data[x + y * width]) * 4
                        let j = (x + y * width) * 4
                        data[j + 0] = palette[i + 0]
                        data[j + 1] = palette[i + 1]
                        data[j + 2] = palette[i + 2]
                        data[j + 3] = i > 0 ? 255 : 0
                    }
                }
            case .rgba:
                for y in 0..<height {
                    for x in 0..<width {
                        let i = (x + y * width) * 4
                        let j = (x + (height - y - 1) * width) * 4
                        data[j + 0] = frame.data[i + 3]
                        data[j + 1] = frame.data[i + 2]
                        data[j + 2] = frame.data[i + 1]
                        data[j + 3] = frame.data[i + 0]
                    }
                }
            }

            if let image = context.makeImage() {
                images.append(image)
            }
        }

        return images
    }
}
