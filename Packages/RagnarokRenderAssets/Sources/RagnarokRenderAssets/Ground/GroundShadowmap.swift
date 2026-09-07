//
//  GroundShadowmap.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/9/5.
//

import Foundation
import RagnarokFileFormats

public struct GroundShadowmap: Sendable {
    private let sliceWidth: Int
    private let sliceHeight: Int

    private let width: Int
    private let height: Int

    private let data: [UInt8]

    public init(gnd: GND) {
        let lightmap = gnd.lightmap
        let sliceWidth = Int(lightmap.sliceWidth)
        let sliceHeight = Int(lightmap.sliceHeight)

        let width = Int(gnd.width)
        let height = Int(gnd.height)

        // Cells with no top surface let the full light through.
        var data = [UInt8](repeating: 255, count: width * sliceWidth * height * sliceHeight)

        for y in 0..<height {
            for x in 0..<width {
                let cube = gnd.cubes[x + y * width]
                guard cube.topSurfaceIndex > -1 else {
                    continue
                }

                let slice = Int(gnd.surfaces[Int(cube.topSurfaceIndex)].lightmapIndex)
                guard slice >= 0, slice < Int(lightmap.sliceCount) else {
                    continue
                }

                for pixelY in 0..<sliceHeight {
                    for pixelX in 0..<sliceWidth {
                        let index = x * sliceWidth + pixelX + (y * sliceHeight + pixelY) * (width * sliceWidth)
                        data[index] = lightmap.shadowmapPixels[lightmap.pixelIndex(inSlice: slice, x: pixelX, y: pixelY)]
                    }
                }
            }
        }

        self.sliceWidth = sliceWidth
        self.sliceHeight = sliceHeight
        self.width = width
        self.height = height
        self.data = data
    }

    /// How much of the world's light reaches `x`, `y`, in 0...1.
    public func shadowFactor(x: Float, y: Float) -> Float {
        guard !data.isEmpty else {
            return 1
        }

        let textureWidth = width * sliceWidth
        let textureHeight = height * sliceHeight

        let originX = pixelIndex(for: x, sliceSize: sliceWidth)
        let originY = pixelIndex(for: y, sliceSize: sliceHeight)

        var total: Float = 0
        for offsetY in -3..<3 {
            for offsetX in -3..<3 {
                let sampleX = min(max(originX + offsetX, 0), textureWidth - 1)
                let sampleY = min(max(originY + offsetY, 0), textureHeight - 1)
                total += Float(data[sampleX + sampleY * textureWidth])
            }
        }

        return total / (6 * 6) / 255
    }

    private func pixelIndex(for coordinate: Float, sliceSize: Int) -> Int {
        let cell = Int(floor(coordinate / 2)) * sliceSize
        let mapCell = Int(floor(coordinate))
        let fraction = coordinate - Float(mapCell)

        // A ground cell spans two map cells, so the second one starts halfway across it.
        let half = sliceSize / 2
        let offset = min((mapCell & 1 == 1 ? half : 0) + Int(fraction * Float(half)), sliceSize - 2)
        return cell + offset
    }
}
