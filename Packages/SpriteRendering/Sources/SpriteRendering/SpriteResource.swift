//
//  SpriteResource.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/14.
//

import CoreGraphics
import FileFormats
import Foundation
import ResourceManagement

final public class SpriteResource: @unchecked Sendable {
    public let act: ACT
    public let spr: SPR

    var palette: PaletteResource?

    var scaleFactor: CGFloat = 1

    private var indexedSpriteImages: [CGImage?]
    private var rgbaSpriteImages: [CGImage?]

    public init(act: ACT, spr: SPR) {
        self.act = act
        self.spr = spr

        indexedSpriteImages = Array(repeating: nil, count: Int(spr.indexedSpriteCount))
        rgbaSpriteImages = Array(repeating: nil, count: Int(spr.rgbaSpriteCount))
    }

    func image(for layer: ACT.Layer) -> CGImage? {
        guard let spriteType = SPR.SpriteType(rawValue: Int(layer.spriteType)) else {
            return nil
        }

        let spriteIndex = Int(layer.spriteIndex)
        let image = image(with: spriteType, at: spriteIndex)
        return image
    }

    private func image(with spriteType: SPR.SpriteType, at spriteIndex: Int) -> CGImage? {
        let indexedSpriteCount = Int(spr.indexedSpriteCount)
        let rgbaSpriteCount = Int(spr.rgbaSpriteCount)

        switch spriteType {
        case .indexed:
            guard 0..<indexedSpriteCount ~= spriteIndex else {
                return nil
            }

            if let image = indexedSpriteImages[spriteIndex] {
                return image
            }

            let index = spriteIndex
            let image = spr.imageForSprite(at: index, palette: palette?.pal)
            indexedSpriteImages[spriteIndex] = image

            return image
        case .rgba:
            guard 0..<rgbaSpriteCount ~= spriteIndex else {
                return nil
            }

            if let image = rgbaSpriteImages[spriteIndex] {
                return image
            }

            let index = indexedSpriteCount + spriteIndex
            let image = spr.imageForSprite(at: index, palette: palette?.pal)
            rgbaSpriteImages[spriteIndex] = image

            return image
        }
    }
}

extension ResourceManager {
    public func sprite(at path: ResourcePath) async throws -> SpriteResource {
        let actPath = path.appendingPathExtension("act")
        async let actData = contentsOfResource(at: actPath)

        let sprPath = path.appendingPathExtension("spr")
        async let sprData = contentsOfResource(at: sprPath)

        let act = try await ACT(data: actData)
        let spr = try await SPR(data: sprData)

        let sprite = SpriteResource(act: act, spr: spr)
        return sprite
    }
}
