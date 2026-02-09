//
//  GroundLightmapAtlas.swift
//  RagnarokRenderers
//
//  Created by Leon Li on 2026/2/9.
//

import Foundation
import CoreGraphics
import RagnarokFileFormats

public struct GroundLightmapAtlas {
    let lightmap: GND.Lightmap

    private let data: [UInt8]
    private let width: Int
    private let height: Int

    public init(lightmap: GND.Lightmap) {
        self.lightmap = lightmap

        let count     = Int(lightmap.count)
        let data      = lightmap.data
        let per_cell  = Int(lightmap.per_cell)

        let width = Int(roundf(sqrtf(Float(count))))
        let height = Int(ceilf(sqrtf(Float(count))))

        let potWidth = Int(powf(2, ceilf(logf(Float(width) * 8) / logf(2))))
        let potHeight = Int(powf(2, ceilf(logf(Float(height) * 8) / logf(2))))

        var out: [UInt8] = Array(repeating: 0, count: potWidth * potHeight * 4)

        for i in 0..<count {
            let pos   = i * 4 * per_cell
            let x     = (i % width) * 8
            let y     = (i / width) * 8

            for _x in 0..<8 {
                for _y in 0..<8 {
                    let idx = ((x + _x) + (y + _y) * potWidth) * 4
                    out[idx + 0] = (data[pos + per_cell + (_x + _y * 8) * 3 + 0] >> 4) << 4 // Posterisation
                    out[idx + 1] = (data[pos + per_cell + (_x + _y * 8) * 3 + 1] >> 4) << 4 // Posterisation
                    out[idx + 2] = (data[pos + per_cell + (_x + _y * 8) * 3 + 2] >> 4) << 4 // Posterisation
                    out[idx + 3] = data[pos + (_x + _y * 8)]
                }
            }
        }

        self.data = out
        self.width = potWidth
        self.height = potHeight
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
            shouldInterpolate: false,
            intent: .defaultIntent
        )
        return image
    }

    func uv(forLightmapSliceIndex i: Int) -> (u1: Float, u2: Float, v1: Float, v2: Float) {
        let l_count_w  = roundf(sqrtf(Float(lightmap.count)))
        let l_count_h  = ceilf(sqrtf(Float(lightmap.count)))
        let l_width    = powf(2, ceilf(logf(l_count_w * 8) / logf(2)))
        let l_height   = powf(2, ceilf(logf(l_count_h * 8) / logf(2)))

        let uv = (
            u1: ((Float(i % Int(l_count_w)) + 0.125) / l_count_w) * ((l_count_w * 8) / l_width),
            u2: ((Float(i % Int(l_count_w)) + 0.875) / l_count_w) * ((l_count_w * 8) / l_width),
            v1: ((Float(i / Int(l_count_w)) + 0.125) / l_count_h) * ((l_count_h * 8) / l_height),
            v2: ((Float(i / Int(l_count_w)) + 0.875) / l_count_h) * ((l_count_h * 8) / l_height)
        )
        return uv
    }
}
