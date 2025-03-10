//
//  AnimatedImage.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/5/8.
//

import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

public struct AnimatedImage: Hashable {
    public var frames: [CGImage?]
    public var frameWidth: CGFloat
    public var frameHeight: CGFloat
    public var frameInterval: CGFloat
    public var frameScale: CGFloat

    public var firstFrame: CGImage? {
        if let firstFrame = frames.first {
            firstFrame
        } else {
            nil
        }
    }

    public init(frames: [CGImage?], frameWidth: CGFloat, frameHeight: CGFloat, frameInterval: CGFloat, frameScale: CGFloat) {
        self.frames = frames
        self.frameWidth = frameWidth
        self.frameHeight = frameHeight
        self.frameInterval = frameInterval
        self.frameScale = frameScale
    }

    public func pngData() -> Data? {
        guard let data = CFDataCreateMutable(kCFAllocatorDefault, 0) else {
            return nil
        }

        guard let imageDestination = CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, frames.count, nil) else {
            return nil
        }

        let properties = [kCGImagePropertyPNGDictionary: [kCGImagePropertyAPNGLoopCount: 1]]
        CGImageDestinationSetProperties(imageDestination, properties as CFDictionary)

        for frame in frames {
            if let frame {
                let properties = [kCGImagePropertyPNGDictionary: [kCGImagePropertyAPNGDelayTime: frameInterval]]
                CGImageDestinationAddImage(imageDestination, frame, properties as CFDictionary)
            }
        }

        CGImageDestinationFinalize(imageDestination)

        return data as Data
    }
}
