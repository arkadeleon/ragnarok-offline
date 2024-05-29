//
//  TransferableImage.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/5/8.
//

import CoreTransferable
import ImageIO

struct TransferableImage: Hashable {
    var name: String
    var image: CGImage
}

extension TransferableImage: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .png) { transferableImage in
            guard let data = transferableImage.image.pngData() else {
                throw NSError(domain: kCFErrorDomainCGImageMetadata as String, code: Int(CGImageMetadataErrors.unknown.rawValue))
            }

            let url = FileManager.default.temporaryDirectory.appending(path: transferableImage.name)
            try data.write(to: url)

            let file = SentTransferredFile(url)
            return file
        }
    }
}
