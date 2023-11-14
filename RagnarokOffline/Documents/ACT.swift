//
//  ACT.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/16.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation

struct ACT {
    var header: Header
    var actions: [Action] = []
    var sounds: [String] = []

    init(data: Data) throws {
        let stream = MemoryStream(data: data)
        let reader = BinaryReader(stream: stream)

        defer {
            reader.close()
        }

        header = try Header(from: reader)

        let actionCount: UInt16 = try reader.readInt()

        // Reserved, unused bytes.
        _ = try reader.readBytes(10)

        for _ in 0..<actionCount {
            let action = try Action(from: reader, version: header.version)
            actions.append(action)
        }

        if header.version >= "2.1" {
            let soundCount: Int32 = try reader.readInt()
            for _ in 0..<soundCount {
                let sound = try reader.readString(40)
                sounds.append(sound)
            }

            if header.version >= "2.2" {
                for i in 0..<actions.count {
                    actions[i].animationSpeed = try reader.readFloat()
                }
            }
        }
    }
}

extension ACT {
    struct Header {
        var magic: String
        var version: String

        init(from reader: BinaryReader) throws {
            magic = try reader.readString(2)
            guard magic == "AC" else {
                throw DocumentError.invalidContents
            }

            let minor: UInt8 = try reader.readInt()
            let major: UInt8 = try reader.readInt()
            version = "\(major).\(minor)"
        }
    }
}

extension ACT {
    struct Action {
        var frames: [Frame] = []
        var animationSpeed: Float = 6

        init(from reader: BinaryReader, version: String) throws {
            let frameCount: UInt32 = try reader.readInt()
            for _ in 0..<frameCount {
                let frame = try Frame(from: reader, version: version)
                frames.append(frame)
            }
        }
    }
}

extension ACT {
    struct Frame {
        var layers: [Layer] = []
        var soundIndex: Int32 = -1
        var anchorPoints: [AnchorPoint] = []

        init(from reader: BinaryReader, version: String) throws {
            // Range1 and Range2, seems to be unused.
            _ = try reader.readBytes(32)

            let layerCount: UInt32 = try reader.readInt()
            for _ in 0..<layerCount {
                let layer = try Layer(from: reader, version: version)
                layers.append(layer)
            }

            if version >= "2.0" {
                soundIndex = try reader.readInt()
            }

            if version >= "2.3" {
                let anchorPointCount: Int32 = try reader.readInt()
                for _ in 0..<anchorPointCount {
                    let anchorPoint = try AnchorPoint(from: reader)
                    anchorPoints.append(anchorPoint)
                }
            }
        }
    }
}

extension ACT {
    struct Layer {
        var offset: simd_int2
        var spriteIndex: Int32
        var isMirrored: Int32
        var color = Palette.Color(red: 255, green: 255, blue: 255, alpha: 255)
        var scale: simd_float2 = [1, 1]
        var rotationAngle: Int32 = 0
        var spriteType: Int32 = 0
        var width: Int32 = 0
        var height: Int32 = 0

        init(from reader: BinaryReader, version: String) throws {
            offset = try [reader.readInt(), reader.readInt()]
            spriteIndex = try reader.readInt()
            isMirrored = try reader.readInt()

            if version >= "2.0" {
                color = try Palette.Color(from: reader)

                scale.x = try reader.readFloat()
                scale.y = scale.x

                if version >= "2.4" {
                    scale.y = try reader.readFloat()
                }

                rotationAngle = try reader.readInt()

                spriteType = try reader.readInt()

                if version >= "2.5" {
                    width = try reader.readInt()
                    height = try reader.readInt()
                }
            }
        }
    }
}

extension ACT {
    struct AnchorPoint {
        var x: Int32
        var y: Int32

        init(from reader: BinaryReader) throws {
            // Unknown bytes.
            _ = try reader.readBytes(4)

            x = try reader.readInt()
            y = try reader.readInt()

            // Unknown bytes.
            _ = try reader.readBytes(4)
        }
    }
}
