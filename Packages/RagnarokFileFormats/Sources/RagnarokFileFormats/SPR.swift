//
//  SPR.swift
//  RagnarokFileFormats
//
//  Created by Leon Li on 2020/5/18.
//

import BinaryIO
import Foundation

public struct SPR: FileFormat {
    public var header: String
    public var version: FileFormatVersion
    public var indexedSpriteCount: Int16
    public var rgbaSpriteCount: Int16
    public var sprites: [SPR.Sprite] = []
    public var palette: PAL?

    public init(from decoder: BinaryDecoder) throws {
        header = try decoder.decode(String.self, lengthOfBytes: 2)
        guard header == "SP" else {
            throw FileFormatError.invalidHeader(header, expected: "SP")
        }

        let minor = try decoder.decode(UInt8.self)
        let major = try decoder.decode(UInt8.self)
        version = FileFormatVersion(major: major, minor: minor)

        indexedSpriteCount = try decoder.decode(Int16.self)

        if version > "1.1" {
            rgbaSpriteCount = try decoder.decode(Int16.self)
        } else {
            rgbaSpriteCount = 0
        }

        if version < "2.1" {
            for _ in 0..<indexedSpriteCount {
                let sprite = try decoder.decode(SPR.Sprite.self, configuration: .indexed)
                sprites.append(sprite)
            }
        } else {
            for _ in 0..<indexedSpriteCount {
                let sprite = try decoder.decode(SPR.Sprite.self, configuration: .indexedRLE)
                sprites.append(sprite)
            }
        }

        for _ in 0..<rgbaSpriteCount {
            let sprite = try decoder.decode(SPR.Sprite.self, configuration: .rgba)
            sprites.append(sprite)
        }

        if version > "1.0" {
            _ = try decoder.decode([UInt8].self, count: decoder.bytesRemaining - 1024)
            palette = try decoder.decode(PAL.self)
        }
    }
}

extension SPR {
    public enum SpriteType: Int, Sendable {
        case indexed = 0
        case rgba = 1
    }

    public struct Sprite: BinaryDecodableWithConfiguration, Sendable {
        public enum BinaryDecodingConfiguration {
            case indexed
            case indexedRLE
            case rgba
        }

        public var type: SPR.SpriteType
        public var width: Int16
        public var height: Int16
        public var data: Data

        public init(from decoder: BinaryDecoder, configuration: BinaryDecodingConfiguration) throws {
            width = try decoder.decode(Int16.self)
            height = try decoder.decode(Int16.self)

            switch configuration {
            case .indexed:
                type = .indexed

                let dataLength = Int(width) * Int(height)
                let data = try decoder.decode([UInt8].self, count: dataLength)
                self.data = Data(data)
            case .indexedRLE:
                type = .indexed

                let dataLength = try decoder.decode(Int16.self)
                let data = try decoder.decode([UInt8].self, count: Int(dataLength))
                self.data = Data(data)
            case .rgba:
                type = .rgba

                let dataLength = Int(width) * Int(height) * 4
                let data = try decoder.decode([UInt8].self, count: dataLength)
                self.data = Data(data)
            }
        }
    }
}
