//
//  SpriteRenderer.swift
//  swift-ro
//
//  Created by Leon Li on 2025/2/17.
//

import CoreGraphics
import ROCore
import ROFileFormats
import simd

//struct BoundingBox {
//    var min: SIMD2<Float>
//    var max: SIMD2<Float>
//
//    init() {
//        min = [.infinity, .infinity]
//        max = [-.infinity, -.infinity]
//    }
//}

//struct Transform {
//    var origin: SIMD2<Float>
//    var size: SIMD2<Float>
//
//    var scale: SIMD2<Float>
//    var rotation: Float
//    var translation: SIMD2<Float>
//
//    var matrix: simd_float3x3 {
//        matrix_identity_float3x3
//    }
//
//    init() {
//        origin = .zero
//        size = .zero
//
//        scale = .one
//        rotation = .zero
//        translation = .zero
//    }
//}

final public class SpriteRenderer {
    struct RenderNode {
        var color: RGBAColor
        var image: CGImage?
//        var offset: SIMD3<Float>
//        var boundingBox: BoundingBox
//        var transformMatrix: simd_float3x3
        var frame: CGRect
        var bounds: CGRect
        var transform: CGAffineTransform
        var children: [RenderNode]

        init() {
            color = RGBAColor(red: 255, green: 255, blue: 255, alpha: 255)
//            offset = .zero
//            boundingBox = BoundingBox()
//            transformMatrix = matrix_identity_float3x3
            frame = .null
            bounds = .null
            transform = .identity
            children = []
        }
    }

    public init() {
    }

    public func drawPlayerSprites(sprites: [SpriteResource], actionIndex: Int) -> [CGImage] {
        var actionNodes: [RenderNode] = []
        var bounds: CGRect = .null

        let startFrameIndex = 0
        var endFrameIndex = 0

        for sprite in sprites {
            let actionNode = actionNode(sprite: sprite, actionIndex: actionIndex)
            actionNodes.append(actionNode)

            bounds = bounds.union(actionNode.bounds)

            endFrameIndex = max(endFrameIndex, actionNode.children.count)
        }

        var images: [CGImage] = []

        for frameIndex in startFrameIndex..<endFrameIndex {
            let renderer = CGImageRenderer(size: bounds.size, flipped: true)

            let image = renderer.image { context in
                for actionNode in actionNodes {
                    var actionIndex = actionIndex
                    var frameIndex = frameIndex

                    let frameNode = actionNode.children[frameIndex]
                    for layerNode in frameNode.children {
                        if let image = layerNode.image {
                            context.saveGState()
                            context.translateBy(x: -bounds.origin.x, y: -bounds.origin.y)
                            context.concatenate(layerNode.transform)
                            context.scaleBy(x: 1, y: -1)
                            context.draw(image, in: layerNode.frame)
                            context.restoreGState()
                        }
                    }
                }
            }

            if let image {
                images.append(image)
            }
        }

        return images
    }

    func actionNode(sprite: SpriteResource, actionIndex: Int) -> RenderNode {
        var actionNode = RenderNode()

        // TODO: Adjusts frame range.

        let action = sprite.act.actions[actionIndex]
        for frameIndex in 0..<action.frames.count {
            let frameNode = frameNode(sprite: sprite, actionIndex: actionIndex, frameIndex: frameIndex)
            actionNode.children.append(frameNode)
            actionNode.bounds = actionNode.bounds.union(frameNode.bounds)
        }

        return actionNode
    }

    func frameNode(sprite: SpriteResource, actionIndex: Int, frameIndex: Int) -> RenderNode {
        var frameNode = RenderNode()

        var parentOffset: SIMD2<Float> = .zero

        if let parent = sprite.parent {
            var parentFrameIndex = frameIndex

            // TODO: Adjusts parent frame index.

            if let parentAnchorPoint = parent.act.actions[actionIndex].frames[parentFrameIndex].anchorPoints.first {
                parentOffset = [Float(parentAnchorPoint.x), Float(parentAnchorPoint.y)]
            }

            if let anchorPoint = sprite.act.actions[actionIndex].frames[frameIndex].anchorPoints.first {
                parentOffset -= [Float(anchorPoint.x), Float(anchorPoint.y)]
            }
        }

        let frame = sprite.act.actions[actionIndex].frames[frameIndex]
        for layer in frame.layers {
            let layerNode = layerNode(sprite: sprite, layer: layer, parentOffset: parentOffset)
            frameNode.children.append(layerNode)
            frameNode.bounds = frameNode.bounds.union(layerNode.bounds)
        }

        return frameNode
    }

    func layerNode(sprite: SpriteResource, layer: ACT.Layer, parentOffset: SIMD2<Float>) -> RenderNode {
        var layerNode = RenderNode()

        guard let image = sprite.image(for: layer) else {
            return layerNode
        }

//        let isMirrored = (layer.isMirrored != 0)
//        var transform = Transform()
//        transform.origin = [0.5, 0.5]
//        transform.size = if isMirrored {
//            [Float(image.width) - 0.5, Float(image.height)]
//        } else {
//            [Float(image.width), Float(image.height)]
//        }
//        transform.scale = if isMirrored {
//            [-layer.scale.x, layer.scale.y]
//        } else {
//            [layer.scale.x, layer.scale.y]
//        }
//        transform.rotation = radians(Float(layer.rotationAngle))
//        transform.translation = [
//            Float(layer.offset.x) + parentOffset.x,
//            Float(layer.offset.y) + parentOffset.y,
//        ]

        layerNode.image = image
        layerNode.color = layer.color

        let width = CGFloat(image.width)
        let height = CGFloat(image.height)
        let rect = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)
        layerNode.frame = rect

        var transform = CGAffineTransformIdentity
        transform = CGAffineTransformTranslate(
            transform,
            CGFloat(layer.offset.x) + CGFloat(parentOffset.x),
            CGFloat(layer.offset.y) + CGFloat(parentOffset.y)
        )
        transform = CGAffineTransformRotate(transform, CGFloat(layer.rotationAngle) / 180 * .pi)
        if layer.isMirrored == 0 {
            transform = CGAffineTransformScale(transform, CGFloat(layer.scale.x), CGFloat(layer.scale.y))
        } else {
            transform = CGAffineTransformScale(transform, -CGFloat(layer.scale.x), CGFloat(layer.scale.y))
        }
        layerNode.transform = transform

        layerNode.bounds = rect.applying(transform)

        return layerNode
    }

//    func bounds(for layer: ACT.Layer, image: CGImage, parentOffset: SIMD2<Float>) -> CGRect {
//        let width = CGFloat(image.width)
//        let height = CGFloat(image.height)
//        let rect = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)
//
//        var transform = CGAffineTransformIdentity
//        transform = CGAffineTransformTranslate(transform, CGFloat(layer.offset.x) + CGFloat(parentOffset.x), CGFloat(layer.offset.y) + CGFloat(parentOffset.y))
//        transform = CGAffineTransformRotate(transform, CGFloat(layer.rotationAngle) / 180 * .pi)
//        if layer.isMirrored == 0 {
//            transform = CGAffineTransformScale(transform, CGFloat(layer.scale.x), CGFloat(layer.scale.y))
//        } else {
//            transform = CGAffineTransformScale(transform, -CGFloat(layer.scale.x), CGFloat(layer.scale.y))
//        }
//
//        let bounds = rect.applying(transform)
//        return bounds
//    }
}
