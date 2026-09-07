//
//  GND+Image.swift
//  RagnarokFileFormats
//
//  Created by Leon Li on 2026/9/7.
//

import CoreGraphics
import Foundation

extension GND {
    public func lightmapImage() -> CGImage? {
        image { lightmap, pixelIndex in
            let color = lightmap.lightmapPixels[pixelIndex]
            return (color.red, color.green, color.blue)
        }
    }

    public func shadowmapImage() -> CGImage? {
        image { lightmap, pixelIndex in
            let intensity = lightmap.shadowmapPixels[pixelIndex]
            return (intensity, intensity, intensity)
        }
    }

    private func image(pixelProvider: (GND.Lightmap, Int) -> (red: UInt8, green: UInt8, blue: UInt8)) -> CGImage? {
        let sliceWidth = Int(lightmap.sliceWidth)
        let sliceHeight = Int(lightmap.sliceHeight)

        let width = Int(self.width) * sliceWidth
        let height = Int(self.height) * sliceHeight
        guard width > 0, height > 0 else {
            return nil
        }

        var data: [UInt8] = Array(repeating: 0, count: width * height * 4)

        for y in 0..<Int(self.height) {
            for x in 0..<Int(self.width) {
                let cube = cubes[x + y * Int(self.width)]
                guard cube.topSurfaceIndex > -1 else {
                    continue
                }

                let slice = Int(surfaces[Int(cube.topSurfaceIndex)].lightmapIndex)
                guard slice >= 0, slice < Int(lightmap.sliceCount) else {
                    continue
                }

                for pixelY in 0..<sliceHeight {
                    for pixelX in 0..<sliceWidth {
                        let pixelIndex = lightmap.pixelIndex(inSlice: slice, x: pixelX, y: pixelY)
                        let (red, green, blue) = pixelProvider(lightmap, pixelIndex)

                        // The map's y grows northwards, but the image's rows grow downwards.
                        let row = height - 1 - (y * sliceHeight + pixelY)
                        let index = ((x * sliceWidth + pixelX) + row * width) * 4
                        data[index + 0] = red
                        data[index + 1] = green
                        data[index + 2] = blue
                        data[index + 3] = 255
                    }
                }
            }
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
}
