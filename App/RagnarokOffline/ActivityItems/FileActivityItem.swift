//
//  FileActivityItem.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/8.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import LinkPresentation
import UIKit
import ROFileSystem

class FileActivityItem: NSObject, UIActivityItemSource {
    let file: File

    init(file: File) {
        self.file = file
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        UIImage()
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        file.contents()
    }

    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        file.name
    }

    func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
        file.type?.identifier ?? ""
    }

    func activityViewController(_ activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: UIActivity.ActivityType?, suggestedSize size: CGSize) -> UIImage? {
        nil
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.originalURL = file.size.map({ URL(fileURLWithPath: "\($0) B") })
        metadata.title = file.name
        metadata.iconProvider = NSItemProvider(object: UIImage())
        return metadata
    }
}

extension File {
    var activityItem: Any? {
        switch self {
        case .directory:
            return nil
        case .regularFile:
            return FileActivityItem(file: self)
        case .grf:
            return url
        case .grfDirectory:
            return nil
        case .grfEntry:
            return FileActivityItem(file: self)
        }
    }
}
