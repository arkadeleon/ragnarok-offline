//
//  ACTDocument+Image.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/10/23.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit

extension ACTDocument {

    func animationForAction(at index: Int, with frames: [CGImage?]) -> (images: [UIImage], duration: Double) {
        let action = actions[index]

        var bounds: CGRect = .zero
        for animation in action.animations {
            for layer in animation.layers {
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

        let images = action.animations.map { (animation) -> UIImage in
            let context = UIGraphicsImageRenderer(bounds: bounds)
            let image = context.image { (context) in
                for layer in animation.layers {
                    let frameIndex = Int(layer.index)
                    guard frameIndex < frames.count, let image = frames[frameIndex] else {
                        continue
                    }
                    let width = CGFloat(layer.width) * CGFloat(layer.scale.x)
                    let height = CGFloat(layer.height) * CGFloat(layer.scale.y)
                    var rect = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)
                    rect = rect.offsetBy(dx: CGFloat(layer.pos.x), dy: CGFloat(layer.pos.y))
                    UIImage(cgImage: image).draw(in: rect)
                }
            }
            return image
        }
        let duration = Double(action.delay / 1000) * Double(images.count)

        return (images: images, duration: duration)
    }
}
