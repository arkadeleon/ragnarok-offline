//
//  GAT+Image.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/19.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import UIKit

extension GAT {
    func image() -> UIImage? {
        let width = Int(width)
        let height = Int(height)

        let colorSpace = CGColorSpaceCreateDeviceGray()

        let byteOrder = CGBitmapInfo.byteOrderDefault
        let alphaInfo = CGImageAlphaInfo.none
        let bitmapInfo = CGBitmapInfo(rawValue: byteOrder.rawValue | alphaInfo.rawValue)

        var data = Data(count: width * height)

        for y in 0..<height {
            for x in 0..<width {
                let index = x + y * width

                if x < 2 || x > width - 3 || y < 2 || y > height - 3 {
                    data[index] = 153
                    continue
                }

                let cell = cells[index]
                switch cell.type {
                case .walkable, .walkable2, .unknown, .walkable3:
                    data[index] = 25
                case .noWalkable, .noWalkableNoSnipable:
                    data[index] = 153
                case .noWalkableSnipable:
                    data[index] = 70
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
        return image.map({ UIImage(cgImage: $0, scale: 1, orientation: .downMirrored) })
    }
}

extension GAT {
    func height(forCellAtX x: Int, y: Int) -> Float {
        let index = x + y * Int(width)
        let cell = cells[index]
        let bottomLeft = cell.bottomLeft
        let bottomRight = cell.bottomRight
        let topLeft = cell.topLeft
        let topRight = cell.topRight

        let x1 = bottomLeft + (bottomRight - bottomLeft) / 2
        let x2 = topLeft + (topRight - topLeft) / 2

        return -(x1 + (x2 - x1) / 2)
    }
}
