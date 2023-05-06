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
        var buffer = ByteBuffer(data: data)

        header = try buffer.readString(length: 2)
        guard header == "SP" else {
            throw DocumentError.invalidContents
        }

        let minor = try buffer.readUInt8()
        let major = try buffer.readUInt8()
        version = "\(major).\(minor)"

        let indexedSpriteCount = try buffer.readUInt16()

        let rgbaSpriteCount: UInt16
        if version > "1.1" {
            rgbaSpriteCount = try buffer.readUInt16()
        } else {
            rgbaSpriteCount = 0
        }

        sprites = []

        if version < "2.1" {
            sprites += try (0..<indexedSpriteCount).map { _ in
                try buffer.readIndexedSprite()
            }
        } else {
            sprites += try (0..<indexedSpriteCount).map { _ in
                try buffer.readIndexedSpriteRLE()
            }
        }

        sprites += try (0..<rgbaSpriteCount).map { _ in
            try buffer.readRGBASprite()
        }

        if version > "1.0" {
            try buffer.moveReaderIndex(to: data.count - 1024)
            let paletteData = try buffer.readData(length: 1024)
            palette = try Palette(data: paletteData)
        }
    }
}

extension SPRDocument {

    func imageForSprite(at index: Int) -> CGImage? {
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
            return image
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

            let transform = CGAffineTransform(1, 0, 0, -1, 0, CGFloat(height))
            context.concatenate(transform)
            context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

            let downMirroredImage = context.makeImage()
            return downMirroredImage
        }
    }
}

extension ByteBuffer {

    @inlinable
    mutating func readIndexedSprite() throws -> SPRSprite {
        let width = try readUInt16()
        let height = try readUInt16()
        let data = try readData(length: Int(width) * Int(height))
        let sprite = SPRSprite(
            type: .indexed,
            width: width,
            height: height,
            data: data
        )
        return sprite
    }

    @inlinable
    mutating func readIndexedSpriteRLE() throws -> SPRSprite {
        let width = try readUInt16()
        let height = try readUInt16()
        var data = Data(capacity: Int(width) * Int(height))

        let endIndex = try Int(readUInt16()) + readerIndex
        while readerIndex < endIndex {
            let c = try readUInt8()
            data.append(c)

            if c == 0 {
                let count = try readUInt8()
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
    mutating func readRGBASprite() throws -> SPRSprite {
        let width = try readUInt16()
        let height = try readUInt16()
        let data = try readData(length: Int(width) * Int(height) * 4)
        let sprite = SPRSprite(
            type: .rgba,
            width: width,
            height: height,
            data: data
        )
        return sprite
    }
}
