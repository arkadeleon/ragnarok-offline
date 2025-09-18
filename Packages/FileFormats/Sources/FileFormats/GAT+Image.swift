//
//  GAT+Image.swift
//  FileFormats
//
//  Created by Leon Li on 2023/11/19.
//

import CoreGraphics
import Foundation

extension GAT {
    public func image() -> CGImage? {
        let width = Int(width)
        let height = Int(height)

        let colorSpace = CGColorSpace(name: CGColorSpace.genericGrayGamma2_2)!

        let byteOrder = CGBitmapInfo.byteOrderDefault
        let alphaInfo = CGImageAlphaInfo.none
        let bitmapInfo = CGBitmapInfo(rawValue: byteOrder.rawValue | alphaInfo.rawValue)

        var data = Data(count: width * height)

        for y in 0..<height {
            for x in 0..<width {
                let tileIndex = x + y * width
                let pixelIndex = x + (height - 1 - y) * width

                if x < 2 || x > width - 3 || y < 2 || y > height - 3 {
                    data[pixelIndex] = 153
                    continue
                }

                let tile = tiles[tileIndex]
                switch tile.type {
                case .walkable, .walkable2, .unknown, .walkable3:
                    data[pixelIndex] = 25
                case .noWalkable, .noWalkableNoSnipable:
                    data[pixelIndex] = 153
                case .noWalkableSnipable:
                    data[pixelIndex] = 70
                }
            }
        }

        guard let provider = CGDataProvider(data: data as CFData) else {
            return nil
        }

        let image = CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 8,
            bytesPerRow: width,
            space: colorSpace,
            bitmapInfo: bitmapInfo,
            provider: provider,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        )
        return image
    }
}
