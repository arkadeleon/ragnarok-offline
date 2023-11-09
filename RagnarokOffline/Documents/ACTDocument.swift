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

    init(from reader: BinaryReader, version: String) throws {
        pos = try [reader.readInt(), reader.readInt()]
        spriteIndex = try reader.readInt()
        isMirrored = try reader.readInt()
        color = [1.0, 1.0, 1.0, 1.0]
        scale = [1.0, 1.0]
        angle = 0
        spriteType = 0
        width = 0
        height = 0

        if version >= "2.0" {
            color[0] = try Float(reader.readInt() as UInt8) / 255
            color[1] = try Float(reader.readInt() as UInt8) / 255
            color[2] = try Float(reader.readInt() as UInt8) / 255
            color[3] = try Float(reader.readInt() as UInt8) / 255
            scale[0] = try reader.readFloat()
            scale[1] = try version <= "2.3" ? scale[0] : reader.readFloat()
            angle = try reader.readInt()
            spriteType = try reader.readInt()

            if version >= "2.5" {
                width = try reader.readInt()
                height = try reader.readInt()
            }
        }
    }
}

struct ACTFrame {
    var layers: [ACTLayer]
    var sound: Int32
    var anchorPoints: [simd_int2]

    init(from reader: BinaryReader, version: String) throws {
        // Range1 and Range2, seems to be unused.
        _ = try reader.readBytes(32)

        let layerCount: UInt32 = try reader.readInt()
        layers = try (0..<layerCount).map { _ in
            try ACTLayer(from: reader, version: version)
        }

        sound = try version >= "2.0" ? reader.readInt() : -1

        anchorPoints = []
        if version >= "2.3" {
            let anchorPointCount: Int32 = try reader.readInt()
            anchorPoints = try (0..<anchorPointCount).map { _ in
                // Unknown bytes.
                _ = try reader.readBytes(4)

                let x: Int32 = try reader.readInt()
                let y: Int32 = try reader.readInt()

                // Unknown bytes.
                _ = try reader.readBytes(4)

                let anchorPoint = simd_int2(x: x, y: y)
                return anchorPoint
            }
        }
    }
}

struct ACTAction {
    var frames: [ACTFrame]
    var delay: Float

    init(from reader: BinaryReader, version: String) throws {
        let frameCount: UInt32 = try reader.readInt()
        frames = try (0..<frameCount).map { _ in
            try ACTFrame(from: reader, version: version)
        }

        delay = 150
    }
}

struct ACTDocument {

    var header: String
    var version: String
    var actions: [ACTAction]
    var sounds: [String]

    init(data: Data) throws {
        let stream = MemoryStream(data: data)
        let reader = BinaryReader(stream: stream)

        defer {
            reader.close()
        }

        header = try reader.readString(2)
        guard header == "AC" else {
            throw DocumentError.invalidContents
        }

        let minor: UInt8 = try reader.readInt()
        let major: UInt8 = try reader.readInt()
        let version = "\(major).\(minor)"
        self.version = version

        let actionCount: UInt16 = try reader.readInt()

        // Reserved, unused bytes.
        _ = try reader.readBytes(10)

        actions = try (0..<actionCount).map { _ in
            try ACTAction(from: reader, version: version)
        }

        sounds = []
        if version >= "2.1" {
            let soundCount: Int32 = try reader.readInt()
            sounds = try (0..<soundCount).map { _ in
                try reader.readString(40)
            }

            if version >= "2.2" {
                for i in 0..<actions.count {
                    actions[i].delay = try reader.readFloat() * 25
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
