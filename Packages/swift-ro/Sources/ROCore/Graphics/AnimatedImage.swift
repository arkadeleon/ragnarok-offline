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
    public var images: [CGImage]
    public var delay: CGFloat

    public var size: CGSize {
        images.reduce(CGSize.zero) { size, image in
            CGSize(
                width: max(size.width, CGFloat(image.width)),
                height: max(size.height, CGFloat(image.height))
            )
        }
    }

    public init(images: [CGImage], delay: CGFloat) {
        self.images = images
        self.delay = delay
    }

    public func pngData() -> Data? {
        guard let data = CFDataCreateMutable(kCFAllocatorDefault, 0) else {
            return nil
        }

        guard let imageDestination = CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, images.count, nil) else {
            return nil
        }

        let properties = [kCGImagePropertyPNGDictionary: [kCGImagePropertyAPNGLoopCount: 1]]
        CGImageDestinationSetProperties(imageDestination, properties as CFDictionary)

        for image in images {
            let properties = [kCGImagePropertyPNGDictionary: [kCGImagePropertyAPNGDelayTime: delay]]
            CGImageDestinationAddImage(imageDestination, image, properties as CFDictionary)
        }

        CGImageDestinationFinalize(imageDestination)

        return data as Data
    }
}
