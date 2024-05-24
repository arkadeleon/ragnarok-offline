//
//  AnimatedImage.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/5/8.
//

import CoreGraphics
import CoreTransferable
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

extension AnimatedImage: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { animatedImage in
            guard let data = animatedImage.pngData() else {
                throw NSError(domain: kCFErrorDomainCGImageMetadata as String, code: Int(CGImageMetadataErrors.unknown.rawValue))
            }
            return data
        }
    }
}

extension AnimatedImage {
    public struct Named: Hashable {
        var name: String
        var image: AnimatedImage
    }

    public func named(_ name: String) -> Named {
        Named(name: name, image: self)
    }
}

extension AnimatedImage.Named: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .png) { namedAnimatedImage in
            guard let data = namedAnimatedImage.image.pngData() else {
                throw NSError(domain: kCFErrorDomainCGImageMetadata as String, code: Int(CGImageMetadataErrors.unknown.rawValue))
            }

            let url = FileManager.default.temporaryDirectory.appending(path: namedAnimatedImage.name)
            try data.write(to: url)

            let file = SentTransferredFile(url)
            return file
        }
    }
}
