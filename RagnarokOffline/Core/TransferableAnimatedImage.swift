//
//  TransferableAnimatedImage.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/29.
//

import CoreTransferable
import ImageIO
import UniformTypeIdentifiers

struct TransferableAnimatedImage: Hashable {
    var animatedImage: AnimatedImage
    var filename: String
}

extension TransferableAnimatedImage: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) {
            if let pngData = $0.animatedImage.pngData() {
                return pngData
            } else {
                throw NSError(
                    domain: kCFErrorDomainCGImageMetadata as String,
                    code: Int(CGImageMetadataErrors.unknown.rawValue)
                )
            }
        }
        .suggestedFileName {
            $0.filename + ".png"
        }
    }
}

extension AnimatedImage {
    func pngData() -> Data? {
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
