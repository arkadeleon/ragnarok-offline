//
//  StillImageActivityItem.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/19.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import LinkPresentation
import UIKit
import UniformTypeIdentifiers
import RagnarokOfflineGraphics

class StillImageActivityItem: NSObject, UIActivityItemSource {
    let stillImage: StillImage
    let filename: String
    let index: Int?

    init(stillImage: StillImage, filename: String, index: Int? = nil) {
        self.stillImage = stillImage
        self.filename = filename
        self.index = index
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        UIImage(cgImage: stillImage.image)
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        stillImage.pngData()
    }

    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        if let index {
            return String(format: "%@.%03d", filename, index)
        } else {
            return filename
        }
    }

    func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
        UTType.png.identifier
    }

    func activityViewController(_ activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: UIActivity.ActivityType?, suggestedSize size: CGSize) -> UIImage? {
        UIImage(cgImage: stillImage.image)
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()

        if let index {
            metadata.originalURL = URL(fileURLWithPath: String(format: "%03d", index))
        }

        metadata.title = filename
        metadata.iconProvider = NSItemProvider(object: UIImage(cgImage: stillImage.image))

        return metadata
    }
}
