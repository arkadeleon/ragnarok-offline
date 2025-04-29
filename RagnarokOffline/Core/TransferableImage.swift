//
//  TransferableImage.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/5/8.
//

import CoreTransferable
import ImageIO

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
