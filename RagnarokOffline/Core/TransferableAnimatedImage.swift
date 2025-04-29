//
//  TransferableAnimatedImage.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/29.
//

import CoreTransferable
import ImageIO
import ROCore

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
