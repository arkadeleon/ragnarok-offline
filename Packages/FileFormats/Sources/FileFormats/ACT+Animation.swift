//
//  ACT+Animation.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/14.
//

import ImageRendering
import QuartzCore

public struct ACTAnimation: Sendable {
    public let frames: [CGImage?]
    public let frameWidth: CGFloat
    public let frameHeight: CGFloat
    public let frameInterval: CGFloat
}

extension ACT.Action {
    public func animation(using imagesBySpriteType: [SPR.SpriteType : [CGImage?]]) -> ACTAnimation {
        let bounds = calculateBounds(using: imagesBySpriteType)

        let frames = self.frames.compactMap { frame -> CGImage? in
            frame.image(in: bounds, using: imagesBySpriteType)
        }
        let frameInterval = CGFloat(animationSpeed) * 25 / 1000
        let animation = ACTAnimation(
            frames: frames,
            frameWidth: bounds.size.width,
            frameHeight: bounds.size.height,
            frameInterval: frameInterval
        )
        return animation
    }

    func calculateBounds(using imagesBySpriteType: [SPR.SpriteType : [CGImage?]]) -> CGRect {
        var bounds: CGRect = .zero
        for frame in frames {
            for layer in frame.layers {
                guard let spriteType = SPR.SpriteType(rawValue: Int(layer.spriteType)),
                      let spriteImages = imagesBySpriteType[spriteType]
                else {
                    continue
                }

                let spriteIndex = Int(layer.spriteIndex)
                guard 0..<spriteImages.count ~= spriteIndex, let image = spriteImages[spriteIndex] else {
                    continue
                }

                let width = CGFloat(image.width)
                let height = CGFloat(image.height)
                var rect = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)

                var transform = CGAffineTransformIdentity
                transform = CGAffineTransformTranslate(transform, CGFloat(layer.offset.x), CGFloat(layer.offset.y))
                transform = CGAffineTransformRotate(transform, CGFloat(layer.rotationAngle) / 180 * .pi)
                if layer.isMirrored == 0 {
                    transform = CGAffineTransformScale(transform, CGFloat(layer.scale.x), CGFloat(layer.scale.y))
                } else {
                    transform = CGAffineTransformScale(transform, -CGFloat(layer.scale.x), CGFloat(layer.scale.y))
                }

                rect = rect.applying(transform)

                bounds = bounds.union(rect)
            }
        }
        return bounds
    }
}

extension ACT.Frame {
    func image(in bounds: CGRect, using imagesBySpriteType: [SPR.SpriteType : [CGImage?]]) -> CGImage? {
        let frameLayer = CALayer()
        frameLayer.bounds = bounds

        for layer in layers {
            guard let caLayer = CALayer(layer: layer, contents: { spriteType, spriteIndex in
                guard let spriteImages = imagesBySpriteType[spriteType] else {
                    return nil
                }
                guard 0..<spriteImages.count ~= spriteIndex else {
                    return nil
                }
                let image = spriteImages[spriteIndex]
                return image
            }) else {
                continue
            }

            frameLayer.addSublayer(caLayer)
        }

        let renderer = CGImageRenderer(size: bounds.size, flipped: true)
        let cgImage = renderer.image { cgContext in
            cgContext.translateBy(x: -bounds.origin.x, y: -bounds.origin.y)
            frameLayer.render(in: cgContext)
        }
        return cgImage
    }
}

extension CALayer {
    convenience init?(layer: ACT.Layer, contents: (SPR.SpriteType, Int) -> CGImage?) {
        guard let spriteType = SPR.SpriteType(rawValue: Int(layer.spriteType)) else {
            return nil
        }

        guard let image = contents(spriteType, Int(layer.spriteIndex)) else {
            return nil
        }

        self.init()

        let width = CGFloat(image.width)
        let height = CGFloat(image.height)
        self.frame = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)

        var transform = CATransform3DIdentity
        transform = CATransform3DTranslate(transform, CGFloat(layer.offset.x), CGFloat(layer.offset.y), 0)
        transform = CATransform3DRotate(transform, CGFloat(layer.rotationAngle) / 180 * .pi, 0, 0, 1)
        if layer.isMirrored == 0 {
            transform = CATransform3DScale(transform, CGFloat(layer.scale.x), CGFloat(layer.scale.y), 1)
        } else {
            transform = CATransform3DScale(transform, -CGFloat(layer.scale.x), CGFloat(layer.scale.y), 1)
        }
        #if os(macOS)
        transform = CATransform3DScale(transform, 1, -1, 1)
        #endif
        self.transform = transform

        if layer.color != RGBAColor(red: 255, green: 255, blue: 255, alpha: 255) {
            self.contents = image.applyingColor(layer.color)
        }

        if self.contents == nil {
            self.contents = image
        }
    }
}
