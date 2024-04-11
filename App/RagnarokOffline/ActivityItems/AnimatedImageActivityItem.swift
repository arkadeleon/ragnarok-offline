//
//  AnimatedImageActivityItem.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/19.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import LinkPresentation
import UIKit
import UniformTypeIdentifiers
import ROGraphics

class AnimatedImageActivityItem: NSObject, UIActivityItemSource {
    let animatedImage: AnimatedImage
    let filename: String
    let index: Int?

    init(animatedImage: AnimatedImage, filename: String, index: Int? = nil) {
        self.animatedImage = animatedImage
        self.filename = filename
        self.index = index
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        animatedImage.images.first.map(UIImage.init) ?? UIImage()
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        animatedImage.pngData()
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
        animatedImage.images.first.map(UIImage.init)
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()

        if let index {
            metadata.originalURL = URL(fileURLWithPath: String(format: "%03d", index))
        }

        metadata.title = filename

        if let image = animatedImage.images.first.map(UIImage.init) {
            metadata.iconProvider = NSItemProvider(object: image)
        }

        return metadata
    }
}
