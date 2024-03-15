//
//  FileThumbnailManager.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/14.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import CoreGraphics
import Foundation

class FileThumbnailManager {
    static let shared = FileThumbnailManager()

    private let generator = FileThumbnailGenerator()
    private let cache = NSCache<NSURL, CGImage>()

    func thumbnailTask(for file: File, scale: CGFloat) -> Task<CGImage?, Error> {
        Task {
            try Task.checkCancellation()

            if let thumbnail = cache.object(forKey: file.url as NSURL) {
                return thumbnail
            }

            try Task.checkCancellation()

            let thumbnail = generator.generateThumbnail(for: file, scale: scale)

            if let thumbnail {
                cache.setObject(thumbnail, forKey: file.url as NSURL)
            }

            try Task.checkCancellation()

            return thumbnail
        }
    }
}
