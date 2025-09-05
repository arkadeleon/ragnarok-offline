//
//  TransferableImage.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/5/8.
//

import CoreTransferable
import ImageIO
import UniformTypeIdentifiers

struct TransferableImage: Hashable {
    var image: CGImage
    var filename: String
}

extension TransferableImage: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) {
            if let pngData = $0.image.pngData() {
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

extension CGImage {
    func pngData() -> Data? {
        guard let data = CFDataCreateMutable(kCFAllocatorDefault, 0) else {
            return nil
        }

        guard let imageDestination = CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil) else {
            return nil
        }

        CGImageDestinationAddImage(imageDestination, self, nil)
        CGImageDestinationFinalize(imageDestination)

        return data as Data
    }
}
