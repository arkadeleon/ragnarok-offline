//
//  ACT+AnimatedImage.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/14.
//

import CoreImage.CIFilterBuiltins
import UIKit
import ROCore

extension ACT {
    public func animatedImage(forActionAt index: Int, imagesForSpritesByType: [SPR.SpriteType : [CGImage?]]) -> AnimatedImage {
        let action = actions[index]

        var bounds: CGRect = .zero
        for frame in action.frames {
            for layer in frame.layers {
                guard let spriteType = SPR.SpriteType(rawValue: Int(layer.spriteType)),
                      let imagesForSprites = imagesForSpritesByType[spriteType]
                else {
                    continue
                }

                let spriteIndex = Int(layer.spriteIndex)
                guard 0..<imagesForSprites.count ~= spriteIndex, let image = imagesForSprites[spriteIndex] else {
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

        let context = CIContext()
        let images = action.frames.compactMap { frame in
            let frameLayer = CALayer()
            frameLayer.bounds = bounds

            for layer in frame.layers {
                guard let caLayer = CALayer(context: context, layer: layer, contents: { spriteType, spriteIndex in
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
            return image.cgImage
        }
        let delay = CGFloat(action.animationSpeed * 25 / 1000)
        let animatedImage = AnimatedImage(images: images, delay: delay)
        return animatedImage
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
