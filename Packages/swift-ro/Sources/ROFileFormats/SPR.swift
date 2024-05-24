//
//  SPR.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/18.
//

import Foundation
import ROStream

public struct SPR: Encodable {
    public var header: String
    public var version: String
    public var sprites: [Sprite] = []
    public var palette: PAL?

    public init(data: Data) throws {
        let stream = MemoryStream(data: data)
        let reader = BinaryReader(stream: stream)

        defer {
            reader.close()
        }

        header = try reader.readString(2)
        guard header == "SP" else {
            throw FileFormatError.invalidHeader(header, expected: "SP")
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

        if version < "2.1" {
            for _ in 0..<indexedSpriteCount {
                let sprite = try Sprite.indexedSprite(from: reader)
                sprites.append(sprite)
            }
        } else {
            for _ in 0..<indexedSpriteCount {
                let sprite = try Sprite.indexedSpriteRLE(from: reader)
                sprites.append(sprite)
            }
        }

        for _ in 0..<rgbaSpriteCount {
            let sprite = try Sprite.rgbaSprite(from: reader)
            sprites.append(sprite)
        }

        if version > "1.0" {
            try stream.seek(-1024, origin: .end)
            let paletteData = try reader.readBytes(1024)
            palette = try PAL(data: Data(paletteData))
        }
    }
}

extension SPR {
    public enum SpriteType: Int, Encodable {
        case indexed = 0
        case rgba = 1
    }

    public struct Sprite: Encodable {
        public var type: SpriteType
        public var width: UInt16
        public var height: UInt16
        public var data: Data

        static func indexedSprite(from reader: BinaryReader) throws -> Sprite {
            let width: UInt16 = try reader.readInt()
            let height: UInt16 = try reader.readInt()

            let dataLength = Int(width) * Int(height)
            let data = try reader.readBytes(dataLength)

            let sprite = SPR.Sprite(
                type: .indexed,
                width: width,
                height: height,
                data: Data(data)
            )
            return sprite
        }

        static func indexedSpriteRLE(from reader: BinaryReader) throws -> Sprite {
            let width: UInt16 = try reader.readInt()
            let height: UInt16 = try reader.readInt()

            let dataLength: UInt16 = try reader.readInt()
            let data = try reader.readBytes(Int(dataLength))

            let sprite = SPR.Sprite(
                type: .indexed,
                width: width,
                height: height,
                data: Data(data)
            )
            return sprite
        }

        static func rgbaSprite(from reader: BinaryReader) throws -> Sprite {
            let width: UInt16 = try reader.readInt()
            let height: UInt16 = try reader.readInt()

            let dataLength = Int(width) * Int(height) * 4
            let data = try reader.readBytes(dataLength)

            let sprite = SPR.Sprite(
                type: .rgba,
                width: width,
                height: height,
                data: Data(data)
            )
            return sprite
        }
    }
}
