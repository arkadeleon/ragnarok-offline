//
//  FileThumbnailManager.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/14.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import UIKit

class FileThumbnailManager {
    static let shared = FileThumbnailManager()

    private let generator = FileThumbnailGenerator()
    private let cache = NSCache<NSURL, UIImage>()

    func thumbnailTask(for file: File) -> Task<UIImage?, Error> {
        Task {
            try Task.checkCancellation()

            if let thumbnail = cache.object(forKey: file.url as NSURL) {
                return thumbnail
            }

            try Task.checkCancellation()

            let thumbnail = generator.generateThumbnail(for: file)

            if let thumbnail {
                cache.setObject(thumbnail, forKey: file.url as NSURL)
            }

            try Task.checkCancellation()

            return thumbnail
        }
    }
}
