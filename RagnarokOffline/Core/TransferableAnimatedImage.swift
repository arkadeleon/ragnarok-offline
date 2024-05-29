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
    var name: String
    var image: AnimatedImage
}

extension TransferableAnimatedImage: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .png) { transferableAnimatedImage in
            guard let data = transferableAnimatedImage.image.pngData() else {
                throw NSError(domain: kCFErrorDomainCGImageMetadata as String, code: Int(CGImageMetadataErrors.unknown.rawValue))
            }

            let url = FileManager.default.temporaryDirectory.appending(path: transferableAnimatedImage.name)
            try data.write(to: url)

            let file = SentTransferredFile(url)
            return file
        }
    }
}
