//
//  SpriteResource.swift
//  RagnarokSprite
//
//  Created by Leon Li on 2025/2/14.
//

import CoreGraphics
import Foundation
import os
import RagnarokFileFormats
import RagnarokResources

final public class SpriteResource: Sendable {
    public let act: ACT
    public let spr: SPR
    public let pal: PAL?

    private let indexedSpriteImages: OSAllocatedUnfairLock<[CGImage?]>
    private let rgbaSpriteImages: OSAllocatedUnfairLock<[CGImage?]>

    public init(act: ACT, spr: SPR, pal: PAL? = nil) {
        self.act = act
        self.spr = spr
        self.pal = pal

        indexedSpriteImages = OSAllocatedUnfairLock(
            initialState: Array(repeating: nil, count: Int(spr.indexedSpriteCount))
        )
        rgbaSpriteImages = OSAllocatedUnfairLock(
            initialState: Array(repeating: nil, count: Int(spr.rgbaSpriteCount))
        )
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

            if let image = indexedSpriteImages.withLock({ $0[spriteIndex] }) {
                return image
            }

            let index = spriteIndex
            let image = spr.imageForSprite(at: index, palette: pal)

            return indexedSpriteImages.withLock { storage in
                if let cachedImage = storage[spriteIndex] {
                    return cachedImage
                }

                storage[spriteIndex] = image
                return image
            }
        case .rgba:
            guard 0..<rgbaSpriteCount ~= spriteIndex else {
                return nil
            }

            if let image = rgbaSpriteImages.withLock({ $0[spriteIndex] }) {
                return image
            }

            let index = indexedSpriteCount + spriteIndex
            let image = spr.imageForSprite(at: index, palette: pal)

            return rgbaSpriteImages.withLock { storage in
                if let cachedImage = storage[spriteIndex] {
                    return cachedImage
                }

                storage[spriteIndex] = image
                return image
            }
        }
    }
}

extension ResourceManager {
    public typealias SpriteAndPalettePath = (spritePath: ResourcePath, palettePath: ResourcePath?)

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

    public func sprite(with path: SpriteAndPalettePath) async throws -> SpriteResource {
        let actPath = path.spritePath.appendingPathExtension("act")
        async let actData = contentsOfResource(at: actPath)

        let sprPath = path.spritePath.appendingPathExtension("spr")
        async let sprData = contentsOfResource(at: sprPath)

        let act = try await ACT(data: actData)
        let spr = try await SPR(data: sprData)

        var pal: PAL?
        if let palettePath = path.palettePath {
            do {
                let palPath = palettePath.appendingPathExtension("pal")
                let palData = try await contentsOfResource(at: palPath)
                pal = try PAL(data: palData)
            } catch {
                logger.warning("Palette error: \(error)")
            }
        }

        let sprite = SpriteResource(act: act, spr: spr, pal: pal)
        return sprite
    }
}
