//
//  GroundTileColorMap.swift
//  RagnarokSceneAssets
//
//  Created by Leon Li on 2026/2/10.
//

import CoreGraphics
import Foundation
import RagnarokFileFormats

public struct GroundTileColorMap {
    private let data: [UInt8]
    private let width: Int
    private let height: Int

    public init(gnd: GND) {
        let width = Int(gnd.width)
        let height = Int(gnd.height)

        var data: [UInt8] = Array(repeating: 0, count: width * height * 4)

        for y in 0..<height {
            for x in 0..<width {
                let cube = gnd.cubes[x + y * width]
                guard cube.topSurfaceIndex > -1 else {
                    continue
                }

                let index = (x + y * width) * 4
                let color = gnd.surfaces[Int(cube.topSurfaceIndex)].color

                data[index + 0] = color.alpha
                data[index + 1] = color.red
                data[index + 2] = color.green
                data[index + 3] = color.blue
            }
        }

        self.data = data
        self.width = width
        self.height = height
    }

    public func makeCGImage() -> CGImage? {
        guard width > 0, height > 0 else {
            return nil
        }

        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue).union(.byteOrder32Big)

        guard let provider = CGDataProvider(data: Data(data) as CFData) else {
            return nil
        }

        return CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo,
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        )
    }
}
