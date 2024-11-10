//
//  ACT.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/16.
//

import Foundation
import ROCore

public struct ACT: BinaryDecodable {
    public var header: String
    public var version: String
    public var actions: [Action] = []
    public var sounds: [String] = []

    public init(data: Data) throws {
        let decoder = BinaryDecoder(data: data)
        self = try decoder.decode(ACT.self)
    }

    public init(from decoder: BinaryDecoder) throws {
        header = try decoder.decodeString(2)
        guard header == "AC" else {
            throw FileFormatError.invalidHeader(header, expected: "AC")
        }

        let minor = try decoder.decode(UInt8.self)
        let major = try decoder.decode(UInt8.self)
        version = "\(major).\(minor)"

        let actionCount = try decoder.decode(Int16.self)

        // Reserved, unused bytes.
        _ = try decoder.decode([UInt8].self, count: 10)

        for _ in 0..<actionCount {
            let action = try decoder.decode(Action.self, configuration: version)
            actions.append(action)
        }

        if version >= "2.1" {
            let soundCount = try decoder.decode(Int32.self)
            for _ in 0..<soundCount {
                let sound = try decoder.decodeString(40)
                sounds.append(sound)
            }

            if version >= "2.2" {
                for i in 0..<actions.count {
                    actions[i].animationSpeed = try decoder.decode(Float.self)
                }
            }
        }
    }
}

extension ACT {
    public struct Action: BinaryDecodableWithConfiguration {
        public var frames: [Frame] = []
        public var animationSpeed: Float = 6

        public init(from decoder: BinaryDecoder, configuration version: String) throws {
            let frameCount = try decoder.decode(Int32.self)
            for _ in 0..<frameCount {
                let frame = try decoder.decode(Frame.self, configuration: version)
                frames.append(frame)
            }
        }
    }
}

extension ACT {
    public struct Frame: BinaryDecodableWithConfiguration {
        public var layers: [Layer] = []
        public var soundIndex: Int32 = -1
        public var anchorPoints: [AnchorPoint] = []

        public init(from decoder: BinaryDecoder, configuration version: String) throws {
            // Range1 and Range2, seems to be unused.
            _ = try decoder.decode([UInt8].self, count: 32)

            let layerCount = try decoder.decode(Int32.self)
            for _ in 0..<layerCount {
                let layer = try decoder.decode(Layer.self, configuration: version)
                layers.append(layer)
            }

            if version >= "2.0" {
                soundIndex = try decoder.decode(Int32.self)
            }

            if version >= "2.3" {
                let anchorPointCount = try decoder.decode(Int32.self)
                for _ in 0..<anchorPointCount {
                    let anchorPoint = try decoder.decode(AnchorPoint.self)
                    anchorPoints.append(anchorPoint)
                }
            }
        }
    }
}

extension ACT {
    public struct Layer: BinaryDecodableWithConfiguration {
        public var offset: SIMD2<Int32>
        public var spriteIndex: Int32
        public var isMirrored: Int32
        public var color = Color(red: 255, green: 255, blue: 255, alpha: 255)
        public var scale: SIMD2<Float> = [1, 1]
        public var rotationAngle: Int32 = 0
        public var spriteType: Int32 = 0
        public var width: Int32 = 0
        public var height: Int32 = 0

        public init(from decoder: BinaryDecoder, configuration version: String) throws {
            offset = try [
                decoder.decode(Int32.self),
                decoder.decode(Int32.self),
            ]
            spriteIndex = try decoder.decode(Int32.self)
            isMirrored = try decoder.decode(Int32.self)

            if version >= "2.0" {
                color = try decoder.decode(Color.self)

                scale.x = try decoder.decode(Float.self)
                scale.y = scale.x

                if version >= "2.4" {
                    scale.y = try decoder.decode(Float.self)
                }

                rotationAngle = try decoder.decode(Int32.self)

                spriteType = try decoder.decode(Int32.self)

                if version >= "2.5" {
                    width = try decoder.decode(Int32.self)
                    height = try decoder.decode(Int32.self)
                }
            }
        }
    }
}

extension ACT {
    public struct AnchorPoint: BinaryDecodable {
        public var x: Int32
        public var y: Int32

        public init(from decoder: BinaryDecoder) throws {
            // Unknown bytes.
            _ = try decoder.decode([UInt8].self, count: 4)

            x = try decoder.decode(Int32.self)
            y = try decoder.decode(Int32.self)

            // Unknown bytes.
            _ = try decoder.decode([UInt8].self, count: 4)
        }
    }
}
