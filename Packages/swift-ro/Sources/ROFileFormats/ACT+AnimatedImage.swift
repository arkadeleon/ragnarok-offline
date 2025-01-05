//
//  ACT+AnimatedImage.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/14.
//

import CoreImage.CIFilterBuiltins
import QuartzCore
import ROCore

public struct ACTActionSpriteAtlas {
    public var image: CGImage?
    public var frameWidth: Float
    public var frameHeight: Float
    public var frameCount: Int
    public var frameInterval: Float
}

extension ACT.Action {
    public func animatedImage(using imagesBySpriteType: [SPR.SpriteType : [CGImage?]]) -> AnimatedImage {
        let bounds = calculateBounds(using: imagesBySpriteType)
        let ciContext = CIContext()

        let images = frames.compactMap { frame -> CGImage? in
            frame.image(in: bounds, ciContext: ciContext, using: imagesBySpriteType)
        }
        let delay = CGFloat(animationSpeed * 25 / 1000)
        let animatedImage = AnimatedImage(images: images, delay: delay)
        return animatedImage
    }

    public func spriteAtlas(using imagesBySpriteType: [SPR.SpriteType : [CGImage?]]) -> ACTActionSpriteAtlas {
        let bounds = calculateBounds(using: imagesBySpriteType)
        let ciContext = CIContext()

        let renderer = CGImageRenderer(size: CGSize(width: bounds.size.width * CGFloat(frames.count), height: bounds.size.height), flipped: false)
        let image = renderer.image { cgContext in
            for frameIndex in 0..<frames.count {
                if let frameImage = frames[frameIndex].image(in: bounds, ciContext: ciContext, using: imagesBySpriteType) {
                    cgContext.draw(frameImage, in: CGRect(x: bounds.size.width * CGFloat(frameIndex), y: 0, width: bounds.size.width, height: bounds.size.height))
                }
            }
        }

        let spriteAtlas = ACTActionSpriteAtlas(
            image: image,
            frameWidth: Float(bounds.size.width),
            frameHeight: Float(bounds.size.height),
            frameCount: frames.count,
            frameInterval: animationSpeed * 25 / 1000
        )
        return spriteAtlas
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
    func image(in bounds: CGRect, ciContext: CIContext, using imagesBySpriteType: [SPR.SpriteType : [CGImage?]]) -> CGImage? {
        let frameLayer = CALayer()
        frameLayer.bounds = bounds

        for layer in layers {
            guard let caLayer = CALayer(context: ciContext, layer: layer, contents: { spriteType, spriteIndex in
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
    convenience init?(context: CIContext, layer: ACT.Layer, contents: (SPR.SpriteType, Int) -> CGImage?) {
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

        if layer.color != Color(red: 255, green: 255, blue: 255, alpha: 255) {
            let colorMatrix = CIFilter.colorMatrix()
            colorMatrix.inputImage = CIImage(cgImage: image)
            colorMatrix.rVector = CIVector(x: CGFloat(layer.color.red) / 255, y: 0, z: 0, w: 0)
            colorMatrix.gVector = CIVector(x: 0, y: CGFloat(layer.color.green) / 255, z: 0, w: 0)
            colorMatrix.bVector = CIVector(x: 0, y: 0, z: CGFloat(layer.color.blue) / 255, w: 0)
            colorMatrix.aVector = CIVector(x: 0, y: 0, z: 0, w: CGFloat(layer.color.alpha) / 255)

            if let outputImage = colorMatrix.outputImage {
                self.contents = context.createCGImage(outputImage, from: outputImage.extent)
            }
        }

        if self.contents == nil {
            self.contents = image
        }
    }
}
