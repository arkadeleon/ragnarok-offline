//
//  ACT.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/16.
//

import Foundation
import ROStream

public struct ACT: Encodable {
    public var header: String
    public var version: String
    public var actions: [Action] = []
    public var sounds: [String] = []

    public init(data: Data) throws {
        let stream = MemoryStream(data: data)
        let reader = BinaryReader(stream: stream)

        defer {
            reader.close()
        }

        header = try reader.readString(2)
        guard header == "AC" else {
            throw FileFormatError.invalidHeader(header, expected: "AC")
        }

        let minor: UInt8 = try reader.readInt()
        let major: UInt8 = try reader.readInt()
        version = "\(major).\(minor)"

        let actionCount: UInt16 = try reader.readInt()

        // Reserved, unused bytes.
        _ = try reader.readBytes(10)

        for _ in 0..<actionCount {
            let action = try Action(from: reader, version: version)
            actions.append(action)
        }

        if version >= "2.1" {
            let soundCount: Int32 = try reader.readInt()
            for _ in 0..<soundCount {
                let sound = try reader.readString(40)
                sounds.append(sound)
            }

            if version >= "2.2" {
                for i in 0..<actions.count {
                    actions[i].animationSpeed = try reader.readFloat()
                }
            }
        }
    }
}

extension ACT {
    public struct Action: Encodable {
        public var frames: [Frame] = []
        public var animationSpeed: Float = 6

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
    public struct Frame: Encodable {
        public var layers: [Layer] = []
        public var soundIndex: Int32 = -1
        public var anchorPoints: [AnchorPoint] = []

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
    public struct Layer: Encodable {
        public var offset: SIMD2<Int32>
        public var spriteIndex: Int32
        public var isMirrored: Int32
        public var color = Color(red: 255, green: 255, blue: 255, alpha: 255)
        public var scale: SIMD2<Float> = [1, 1]
        public var rotationAngle: Int32 = 0
        public var spriteType: Int32 = 0
        public var width: Int32 = 0
        public var height: Int32 = 0

        init(from reader: BinaryReader, version: String) throws {
            offset = try [reader.readInt(), reader.readInt()]
            spriteIndex = try reader.readInt()
            isMirrored = try reader.readInt()

            if version >= "2.0" {
                color = try Color(from: reader)

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
    public struct AnchorPoint: Encodable {
        public var x: Int32
        public var y: Int32

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
