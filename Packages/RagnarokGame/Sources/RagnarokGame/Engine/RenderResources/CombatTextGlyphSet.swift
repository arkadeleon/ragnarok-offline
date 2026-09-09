//
//  CombatTextGlyphSet.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/4/23.
//

import CoreGraphics
import Foundation
import RagnarokCore
import RagnarokResources
import RagnarokSprite
import simd

enum CombatTextGlyph: String, CaseIterable, Sendable {
    case zero = "0"
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case thousand = "k"
    case million = "m"
    case miss = "miss"
}

struct CombatTextGlyphGeometry: Sendable {
    /// Glyph size in sprite pixels.
    let size: SIMD2<Float>
    /// Upper left corner in the atlas.
    let minTextureCoordinate: SIMD2<Float>
    /// Lower right corner in the atlas.
    let maxTextureCoordinate: SIMD2<Float>
}

struct CombatTextGlyphSet: Sendable {
    let atlasImage: CGImage?
    let geometries: [CombatTextGlyph : CombatTextGlyphGeometry]

    init(resourceManager: ResourceManager) async throws {
        let effectSpriteDirectory = ResourcePath.spriteDirectory.appending(K2L("이팩트"))
        let numberPath = effectSpriteDirectory.appending(K2L("숫자"))
        let messagePath = effectSpriteDirectory.appending("msg")

        let numberSprite = try await resourceManager.sprite(at: numberPath)
        let messageSprite = try await resourceManager.sprite(at: messagePath)

        var glyphImages: [CombatTextGlyph : CGImage] = [:]
        glyphImages[.zero] = numberSprite.spr.imageForSprite(at: 0)
        glyphImages[.one] = numberSprite.spr.imageForSprite(at: 1)
        glyphImages[.two] = numberSprite.spr.imageForSprite(at: 2)
        glyphImages[.three] = numberSprite.spr.imageForSprite(at: 3)
        glyphImages[.four] = numberSprite.spr.imageForSprite(at: 4)
        glyphImages[.five] = numberSprite.spr.imageForSprite(at: 5)
        glyphImages[.six] = numberSprite.spr.imageForSprite(at: 6)
        glyphImages[.seven] = numberSprite.spr.imageForSprite(at: 7)
        glyphImages[.eight] = numberSprite.spr.imageForSprite(at: 8)
        glyphImages[.nine] = numberSprite.spr.imageForSprite(at: 9)
        glyphImages[.thousand] = numberSprite.spr.imageForSprite(at: 10)
        glyphImages[.million] = numberSprite.spr.imageForSprite(at: 11)
        glyphImages[.miss] = messageSprite.spr.imageForSprite(at: 0)

        self.init(glyphImages: glyphImages)
    }

    init(glyphImages: [CombatTextGlyph : CGImage]) {
        let gutter = 2

        let allGlyphs = CombatTextGlyph.allCases

        let width = allGlyphs.reduce(0) { width, glyph in
            if let image = glyphImages[glyph] {
                width + image.width + gutter
            } else {
                width
            }
        }
        let height = allGlyphs.reduce(0) { height, glyph in
            if let image = glyphImages[glyph] {
                max(height, image.height)
            } else {
                height
            }
        }
        guard width > 0, height > 0 else {
            atlasImage = nil
            geometries = [:]
            return
        }

        var x = 0
        var glyphFrames: [CombatTextGlyph : CGRect] = [:]
        for glyph in allGlyphs {
            guard let image = glyphImages[glyph] else {
                continue
            }

            let y = (height - image.height) / 2
            glyphFrames[glyph] = CGRect(x: x, y: y, width: image.width, height: image.height)
            x += image.width + gutter
        }

        let renderer = CGImageRenderer(size: CGSize(width: width, height: height), flipped: false)
        atlasImage = renderer.image { context in
            for glyph in allGlyphs {
                if let image = glyphImages[glyph], let frame = glyphFrames[glyph] {
                    context.draw(image, in: frame)
                }
            }
        }

        // The atlas is drawn bottom up but sampled top down, so the frame's top
        // edge is the glyph's smallest texture coordinate.
        geometries = Dictionary(uniqueKeysWithValues: allGlyphs.compactMap { glyph in
            guard let frame = glyphFrames[glyph] else {
                return nil
            }

            let geometry = CombatTextGlyphGeometry(
                size: SIMD2(Float(frame.width), Float(frame.height)),
                minTextureCoordinate: SIMD2(
                    Float(frame.minX) / Float(width),
                    Float(CGFloat(height) - frame.maxY) / Float(height)
                ),
                maxTextureCoordinate: SIMD2(
                    Float(frame.maxX) / Float(width),
                    Float(CGFloat(height) - frame.minY) / Float(height)
                )
            )
            return (glyph, geometry)
        })
    }

    subscript(glyph: CombatTextGlyph) -> CombatTextGlyphGeometry? {
        geometries[glyph]
    }

    func geometries(for amount: Int) -> [CombatTextGlyphGeometry] {
        guard amount >= 0 else {
            return []
        }

        let text = String(amount)
        let geometries = text.compactMap { character -> CombatTextGlyphGeometry? in
            guard let glyph = CombatTextGlyph(rawValue: String(character)) else {
                return nil
            }
            return self.geometries[glyph]
        }

        // Drop the whole number rather than spell it with holes in it.
        return geometries.count == text.count ? geometries : []
    }
}
