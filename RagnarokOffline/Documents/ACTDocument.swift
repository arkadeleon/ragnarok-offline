//
//  ACTDocument.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/16.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit

struct ACTLayer {
    var pos: simd_int2
    var sprIndex: Int32
    var isMirrored: Int32
    var color: simd_float4
    var scale: simd_float2
    var angle: Int32
    var sprType: Int32
    var width: Int32
    var height: Int32
}

struct ACTFrame {
    var layers: [ACTLayer]
    var sound: Int32
    var anchorPoints: [simd_int2]
}

struct ACTAction {
    var frames: [ACTFrame]
    var delay: Float
}

struct ACTDocument {

    var header: String
    var version: String
    var actions: [ACTAction]
    var sounds: [String]

    init(data: Data) throws {
        var buffer = ByteBuffer(data: data)

        header = try buffer.readString(length: 2)
        guard header == "AC" else {
            throw DocumentError.invalidContents
        }

        let minor = try buffer.readUInt8()
        let major = try buffer.readUInt8()
        let version = "\(major).\(minor)"
        self.version = version

        let actionCount = try buffer.readUInt16()

        // Reserved, unused bytes.
        try buffer.moveReaderIndex(forwardBy: 10)

        actions = try (0..<actionCount).map { _ in
            try buffer.readAction(version: version)
        }

        sounds = []
        if version >= "2.1" {
            let soundCount = try buffer.readInt32()
            sounds = try (0..<soundCount).map { _ in
                try buffer.readString(length: 40)
            }

            if version >= "2.2" {
                for var action in actions {
                    action.delay = try buffer.readFloat32() * 25
                }
            }
        }
    }
}

extension ACTDocument {

    func animatedImageForAction(at index: Int, with frames: [UIImage?]) -> UIImage? {
        let action = actions[index]

        var bounds: CGRect = .zero
        for frame in action.frames {
            for layer in frame.layers {
                let width = CGFloat(layer.width) * CGFloat(layer.scale.x)
                let height = CGFloat(layer.height) * CGFloat(layer.scale.y)
                var rect = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)
                rect = rect.offsetBy(dx: CGFloat(layer.pos.x), dy: CGFloat(layer.pos.y))
                bounds = bounds.union(rect)
            }
        }

        let halfWidth = max(abs(bounds.minX), abs(bounds.maxX))
        let halfHeight = max(abs(bounds.minY), abs(bounds.maxY))
        bounds = CGRect(x: -halfWidth, y: -halfHeight, width: halfWidth * 2, height: halfHeight * 2)

        let images = action.frames.map { frame -> UIImage in
            let context = UIGraphicsImageRenderer(bounds: bounds)
            let image = context.image { (context) in
                for layer in frame.layers {
                    let frameIndex = Int(layer.sprIndex)
                    guard 0..<frames.count ~= frameIndex, let image = frames[frameIndex] else {
                        continue
                    }
                    let width = CGFloat(layer.width) * CGFloat(layer.scale.x)
                    let height = CGFloat(layer.height) * CGFloat(layer.scale.y)
                    var rect = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)
                    rect = rect.offsetBy(dx: CGFloat(layer.pos.x), dy: CGFloat(layer.pos.y))
                    image.draw(in: rect)
                }
            }
            return image
        }
        let duration = Double(action.delay / 1000) * Double(images.count)
        let animatedImage = UIImage.animatedImage(with: images, duration: duration)
        return animatedImage
    }
}

extension ByteBuffer {

    @inlinable
    mutating func readAction(version: String) throws -> ACTAction {
        let frameCount = try readUInt32()
        let frames = try (0..<frameCount).map { _ in
            try readActionFrame(version: version)
        }
        let action = ACTAction(
            frames: frames,
            delay: 150
        )
        return action
    }

    @inlinable
    mutating func readActionFrame(version: String) throws -> ACTFrame {
        // Range1 and Range2, seems to be unused.
        try moveReaderIndex(forwardBy: 32)

        let layerCount = try readUInt32()
        let layers = try (0..<layerCount).map { _ in
            try readActionFrameLayer(version: version)
        }

        let sound = try version >= "2.0" ? readInt32() : -1

        var anchorPoints: [simd_int2] = []
        if version >= "2.3" {
            let anchorPointCount = try readInt32()
            anchorPoints = try (0..<anchorPointCount).map { _ in
                try readActionFrameAnchorPoint()
            }
        }

        return ACTFrame(
            layers: layers,
            sound: sound,
            anchorPoints: anchorPoints
        )
    }

    @inlinable
    mutating func readActionFrameLayer(version: String) throws -> ACTLayer {
        var layer = try ACTLayer(
            pos: [readInt32(), readInt32()],
            sprIndex: readInt32(),
            isMirrored: readInt32(),
            color: [1.0, 1.0, 1.0, 1.0],
            scale: [1.0, 1.0],
            angle: 0,
            sprType: 0,
            width: 0,
            height: 0
        )

        if version >= "2.0" {
            layer.color[0] = try Float(readUInt8()) / 255
            layer.color[1] = try Float(readUInt8()) / 255
            layer.color[2] = try Float(readUInt8()) / 255
            layer.color[3] = try Float(readUInt8()) / 255
            layer.scale[0] = try readFloat32()
            layer.scale[1] = try version <= "2.3" ? layer.scale[0] : readFloat32()
            layer.angle = try readInt32()
            layer.sprType = try readInt32()

            if version >= "2.5" {
                layer.width = try readInt32()
                layer.height = try readInt32()
            }
        }

        return layer
    }

    @inlinable
    mutating func readActionFrameAnchorPoint() throws -> simd_int2 {
        // Unknown bytes.
        try moveReaderIndex(forwardBy: 4)

        let x = try readInt32()
        let y = try readInt32()

        // Unknown bytes.
        try moveReaderIndex(forwardBy: 4)

        let anchorPoint = simd_int2(x: x, y: y)
        return anchorPoint
    }
}
