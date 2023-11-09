//
//  SPRDocument.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/18.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import CoreGraphics

enum SPRSpriteType: Int {
    case indexed = 0
    case rgba = 1
}

struct SPRSprite {
    var type: SPRSpriteType
    var width: UInt16
    var height: UInt16
    var data: Data
}

struct SPRDocument {

    var header: String
    var version: String
    var sprites: [SPRSprite]
    var palette: Palette?

    init(data: Data) throws {
        let stream = MemoryStream(data: data)
        let reader = BinaryReader(stream: stream)

        defer {
            reader.close()
        }

        header = try reader.readString(2)
        guard header == "SP" else {
            throw DocumentError.invalidContents
        }

        let minor: UInt8 = try reader.readInt()
        let major: UInt8 = try reader.readInt()
        version = "\(major).\(minor)"

        let indexedSpriteCount: UInt16 = try reader.readInt()

        let rgbaSpriteCount: UInt16
        if version > "1.1" {
            rgbaSpriteCount = try reader.readInt()
        } else {
            rgbaSpriteCount = 0
        }

        sprites = []

        if version < "2.1" {
            sprites += try (0..<indexedSpriteCount).map { _ in
                try reader.readIndexedSprite()
            }
        } else {
            sprites += try (0..<indexedSpriteCount).map { _ in
                try reader.readIndexedSpriteRLE()
            }
        }

        sprites += try (0..<rgbaSpriteCount).map { _ in
            try reader.readRGBASprite()
        }

        if version > "1.0" {
            try stream.seek(-1024, origin: .end)
            let paletteData = try reader.readBytes(1024)
            palette = try Palette(data: Data(paletteData))
        }
    }
}

extension SPRDocument {

    func imageForSprite(at index: Int) -> StillImage? {
        let sprite = sprites[index]
        let width = Int(sprite.width)
        let height = Int(sprite.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        switch sprite.type {
        case .indexed:
            guard let palette else {
                return nil
            }

            let byteOrder = CGBitmapInfo.byteOrder32Big
            let alphaInfo = CGImageAlphaInfo.last
            let bitmapInfo = CGBitmapInfo(rawValue: byteOrder.rawValue | alphaInfo.rawValue)

            let data = sprite.data
                .map { colorIndex in
                    var color = palette.colors[Int(colorIndex)]
                    color.alpha = colorIndex == 0 ? 0 : 255
                    return [color.red, color.green, color.blue, color.alpha]
                }
                .flatMap({ $0 })
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
                shouldInterpolate: true,
                intent: .defaultIntent
            )
            return image.map(StillImage.init)
        case .rgba:
            let byteOrder = CGBitmapInfo.byteOrder32Little
            let alphaInfo = CGImageAlphaInfo.last
            let bitmapInfo = CGBitmapInfo(rawValue: byteOrder.rawValue | alphaInfo.rawValue)

            guard let provider = CGDataProvider(data: sprite.data as CFData) else {
                return nil
            }

            guard let image = CGImage(
                width: width,
                height: height,
                bitsPerComponent: 8,
                bitsPerPixel: 32,
                bytesPerRow: width * 4,
                space: colorSpace,
                bitmapInfo: bitmapInfo,
                provider: provider,
                decode: nil,
                shouldInterpolate: true,
                intent: .defaultIntent
            ) else {
                return nil
            }

            guard let context = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: colorSpace,
                bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
            ) else {
                return nil
            }

            // Flip vertically
            let transform = CGAffineTransform(1, 0, 0, -1, 0, CGFloat(height))
            context.concatenate(transform)

            context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

            let downMirroredImage = context.makeImage()
            return downMirroredImage.map(StillImage.init)
        }
    }
}

extension BinaryReader {

    @inlinable
    func readIndexedSprite() throws -> SPRSprite {
        let width: UInt16 = try readInt()
        let height: UInt16 = try readInt()
        let data = try readBytes(Int(width) * Int(height))
        let sprite = SPRSprite(
            type: .indexed,
            width: width,
            height: height,
            data: Data(data)
        )
        return sprite
    }

    @inlinable
    func readIndexedSpriteRLE() throws -> SPRSprite {
        let width: UInt16 = try readInt()
        let height: UInt16 = try readInt()
        var data = Data(capacity: Int(width) * Int(height))

        let endIndex = try Int(readInt() as UInt16) + stream.position
        while stream.position < endIndex {
            let c: UInt8 = try readInt()
            data.append(c)

            if c == 0 {
                let count: UInt8 = try readInt()
                if count == 0 {
                    data.append(count)
                } else {
                    for _ in 1..<count {
                        data.append(c)
                    }
                }
            }
        }

        let sprite = SPRSprite(
            type: .indexed,
            width: width,
            height: height,
            data: data
        )
        return sprite
    }

    @inlinable
    func readRGBASprite() throws -> SPRSprite {
        let width: UInt16 = try readInt()
        let height: UInt16 = try readInt()
        let data = try readBytes(Int(width) * Int(height) * 4)
        let sprite = SPRSprite(
            type: .rgba,
            width: width,
            height: height,
            data: Data(data)
        )
        return sprite
    }
}
