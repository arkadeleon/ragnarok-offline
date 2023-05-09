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
    var spriteIndex: Int32
    var isMirrored: Int32
    var color: simd_float4
    var scale: simd_float2
    var angle: Int32
    var spriteType: Int32
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
                for i in 0..<actions.count {
                    actions[i].delay = try buffer.readFloat32() * 25
                }
            }
        }
    }
}

extension ACTDocument {

    func animatedImageForAction(at index: Int, imagesForSpritesByType: [SPRSpriteType : [CGImage?]]) -> AnimatedImage? {
        let action = actions[index]

        var bounds: CGRect = .zero
        for frame in action.frames {
            for layer in frame.layers {
                guard let caLayer = CALayer(layer: layer, contents: { spriteType, spriteIndex in
                    guard let imagesForSprites = imagesForSpritesByType[spriteType] else {
                        return nil
                    }
                    guard 0..<imagesForSprites.count ~= spriteIndex else {
                        return nil
                    }
                    let image = imagesForSprites[spriteIndex]
                    return image
                }) else {
                    continue
                }

                bounds = bounds.union(caLayer.frame)
            }
        }

//        let halfWidth = max(abs(bounds.minX), abs(bounds.maxX))
//        let halfHeight = max(abs(bounds.minY), abs(bounds.maxY))
//        bounds = CGRect(x: -halfWidth, y: -halfHeight, width: halfWidth * 2, height: halfHeight * 2)

        let images = action.frames.map { frame in
            let frameLayer = CALayer()
            frameLayer.bounds = bounds

            for layer in frame.layers {
                guard let caLayer = CALayer(layer: layer, contents: { spriteType, spriteIndex in
                    guard let imagesForSprites = imagesForSpritesByType[spriteType] else {
                        return nil
                    }
                    guard 0..<imagesForSprites.count ~= spriteIndex else {
                        return nil
                    }
                    let image = imagesForSprites[spriteIndex]
                    return image
                }) else {
                    continue
                }

                frameLayer.addSublayer(caLayer)
            }

            let format = UIGraphicsImageRendererFormat()
            format.scale = 1

            let renderer = UIGraphicsImageRenderer(bounds: bounds, format: format)
            let image = renderer.image { context in
                frameLayer.render(in: context.cgContext)
            }
            return image.cgImage!
        }
        let delay = CGFloat(action.delay / 1000)
        let animatedImage = AnimatedImage(images: images, delay: delay)
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
            spriteIndex: readInt32(),
            isMirrored: readInt32(),
            color: [1.0, 1.0, 1.0, 1.0],
            scale: [1.0, 1.0],
            angle: 0,
            spriteType: 0,
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
            layer.spriteType = try readInt32()

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

extension CALayer {

    convenience init?(layer: ACTLayer, contents: (SPRSpriteType, Int) -> CGImage?) {
        guard let spriteType = SPRSpriteType(rawValue: Int(layer.spriteType)) else {
            return nil
        }

        guard let image = contents(spriteType, Int(layer.spriteIndex)) else {
            return nil
        }

        let width = CGFloat(image.width) * CGFloat(layer.scale.x)
        let height = CGFloat(image.height) * CGFloat(layer.scale.y)
        var rect = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)
        rect = rect.offsetBy(dx: CGFloat(layer.pos.x), dy: CGFloat(layer.pos.y))

        var transform = CATransform3DIdentity
        transform = CATransform3DRotate(transform, CGFloat(layer.angle) / 180 * .pi, 0, 0, 1)

        if layer.isMirrored != 0 {
            transform = CATransform3DScale(transform, -1, 1, 1)
        }

        self.init()
        self.frame = rect
        self.transform = transform
        self.contents = image
    }
}
