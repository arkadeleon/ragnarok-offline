//
//  StillImage.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/5/8.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import CoreGraphics
import CoreTransferable
import ImageIO
import UniformTypeIdentifiers

struct StillImage: Hashable {
    var image: CGImage

    func pngData() -> Data? {
        guard let data = CFDataCreateMutable(kCFAllocatorDefault, 0) else {
            return nil
        }

        guard let imageDestination = CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil) else {
            return nil
        }

        CGImageDestinationAddImage(imageDestination, image, nil)
        CGImageDestinationFinalize(imageDestination)

        return data as Data
    }
}

extension StillImage: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { stillImage in
            guard let data = stillImage.pngData() else {
                throw NSError(domain: kCFErrorDomainCGImageMetadata as String, code: Int(CGImageMetadataErrors.unknown.rawValue))
            }
            return data
        }
    }
}

extension StillImage {
    struct Named: Hashable {
        var name: String
        var image: StillImage
    }

    func named(_ name: String) -> Named {
        Named(name: name, image: self)
    }
}

extension StillImage.Named: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .png) { namedStillImage in
            guard let data = namedStillImage.image.pngData() else {
                throw NSError(domain: kCFErrorDomainCGImageMetadata as String, code: Int(CGImageMetadataErrors.unknown.rawValue))
            }

            let url = FileManager.default.temporaryDirectory.appending(path: namedStillImage.name)
            try data.write(to: url)

            let file = SentTransferredFile(url)
            return file
        }
    }
}
