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
        FileRepresentation(exportedContentType: .png) { transferableAnimatedImage in
            guard let data = transferableAnimatedImage.animatedImage.pngData() else {
                throw NSError(domain: kCFErrorDomainCGImageMetadata as String, code: Int(CGImageMetadataErrors.unknown.rawValue))
            }

            let url = FileManager.default.temporaryDirectory.appending(path: transferableAnimatedImage.filename)
            try data.write(to: url)

            let file = SentTransferredFile(url)
            return file
        }
    }
}
