//
//  ACT+AnimatedImage.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/14.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import UIKit

extension ACT {
    func animatedImage(forActionAt index: Int, imagesForSpritesByType: [SPR.SpriteType : [CGImage?]]) -> AnimatedImage {
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

                let width = CGFloat(image.width) * CGFloat(layer.scale.x)
                let height = CGFloat(image.height) * CGFloat(layer.scale.y)
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

        let images = action.frames.compactMap { frame in
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
            return image.cgImage
        }
        let delay = CGFloat(action.animationSpeed * 25 / 1000)
        let animatedImage = AnimatedImage(images: images, delay: delay)
        return animatedImage
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

        let width = CGFloat(image.width) * CGFloat(layer.scale.x)
        let height = CGFloat(image.height) * CGFloat(layer.scale.y)
        let rect = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)

        var transform = CATransform3DIdentity

        transform = CATransform3DTranslate(transform, CGFloat(layer.offset.x), CGFloat(layer.offset.y), 0)

        transform = CATransform3DRotate(transform, CGFloat(layer.rotationAngle) / 180 * .pi, 0, 0, 1)

        if layer.isMirrored == 0 {
            transform = CATransform3DScale(transform, CGFloat(layer.scale.x), CGFloat(layer.scale.y), 1)
        } else {
            transform = CATransform3DScale(transform, -CGFloat(layer.scale.x), CGFloat(layer.scale.y), 1)
        }

        self.init()
        self.frame = rect
        self.transform = transform
        self.contents = image
    }
}
