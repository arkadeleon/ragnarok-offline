//
//  GroundTextureAtlas.swift
//  RagnarokRenderers
//
//  Created by Leon Li on 2026/2/9.
//

import CoreGraphics
import ImageRendering
import RagnarokFileFormats

public struct GroundTextureAtlas {
    public let gnd: GND

    private let ATLAS_COLS: Float
    private let ATLAS_ROWS: Float
    private let ATLAS_WIDTH: Float
    private let ATLAS_HEIGHT: Float
    private let ATLAS_FACTOR_U: Float
    private let ATLAS_FACTOR_V: Float
    private let ATLAS_PX_U: Float
    private let ATLAS_PX_V: Float

    public init(gnd: GND) {
        self.gnd = gnd

        ATLAS_COLS = roundf(sqrtf(Float(gnd.textures.count)))
        ATLAS_ROWS = ceilf(sqrtf(Float(gnd.textures.count)))
        ATLAS_WIDTH = powf(2, ceilf(logf(ATLAS_COLS * 258) / logf(2)))
        ATLAS_HEIGHT = powf(2, ceilf(logf(ATLAS_ROWS * 258) / logf(2)))
        ATLAS_FACTOR_U = (ATLAS_COLS * 258) / ATLAS_WIDTH
        ATLAS_FACTOR_V = (ATLAS_ROWS * 258) / ATLAS_HEIGHT
        ATLAS_PX_U = 1 / 258
        ATLAS_PX_V = 1 / 258
    }

    public func makeCGImage(textureImages: [String : CGImage]) -> CGImage? {
        let renderer = CGImageRenderer(size: CGSize(width: Int(ATLAS_WIDTH), height: Int(ATLAS_HEIGHT)), flipped: false)
        let image = renderer.image { context in
            context.setFillColor(CGColor(gray: 1, alpha: 1))
            context.fill(CGRect(x: 0, y: 0, width: Int(ATLAS_WIDTH), height: Int(ATLAS_HEIGHT)))

            for (i, name) in gnd.textures.enumerated() {
                guard let textureImage = textureImages[name]?.verticallyFlipped() else {
                    continue
                }

                let x = (i % Int(ATLAS_COLS)) * 258
                let y = (i / Int(ATLAS_COLS)) * 258
                context.draw(textureImage, in: CGRect(x: x, y: y, width: 258, height: 258)) // generate border
                context.draw(textureImage, in: CGRect(x: x + 1, y: y + 1, width: 256, height: 256))
            }
        }
        return image
    }

    func uv(for surface: GND.Surface) -> (u: SIMD4<Float>, v: SIMD4<Float>) {
        let u = Float(Int(surface.textureIndex) % Int(ATLAS_COLS))
        let v = floorf(Float(surface.textureIndex) / ATLAS_COLS)
        let uv = (
            u: SIMD4<Float>(
                (u + surface.u[0] * (1 - ATLAS_PX_U * 2) + ATLAS_PX_U) * ATLAS_FACTOR_U / ATLAS_COLS,
                (u + surface.u[1] * (1 - ATLAS_PX_U * 2) + ATLAS_PX_U) * ATLAS_FACTOR_U / ATLAS_COLS,
                (u + surface.u[2] * (1 - ATLAS_PX_U * 2) + ATLAS_PX_U) * ATLAS_FACTOR_U / ATLAS_COLS,
                (u + surface.u[3] * (1 - ATLAS_PX_U * 2) + ATLAS_PX_U) * ATLAS_FACTOR_U / ATLAS_COLS
            ),
            v: SIMD4<Float>(
                (v + surface.v[0] * (1 - ATLAS_PX_V * 2) + ATLAS_PX_V) * ATLAS_FACTOR_V / ATLAS_ROWS,
                (v + surface.v[1] * (1 - ATLAS_PX_V * 2) + ATLAS_PX_V) * ATLAS_FACTOR_V / ATLAS_ROWS,
                (v + surface.v[2] * (1 - ATLAS_PX_V * 2) + ATLAS_PX_V) * ATLAS_FACTOR_V / ATLAS_ROWS,
                (v + surface.v[3] * (1 - ATLAS_PX_V * 2) + ATLAS_PX_V) * ATLAS_FACTOR_V / ATLAS_ROWS
            )
        )
        return uv
    }
}
