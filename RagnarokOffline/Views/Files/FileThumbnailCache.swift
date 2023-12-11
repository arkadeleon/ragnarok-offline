//
//  FileThumbnailCache.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/24.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import Foundation

class FileThumbnailCache {
    private class CachedThumbnail {
        let thumbnail: FileThumbnailRepresentation

        init(thumbnail: FileThumbnailRepresentation) {
            self.thumbnail = thumbnail
        }
    }

    static let shared = FileThumbnailCache()

    private let generator = FileThumbnailGenerator()
    private let cache = NSCache<NSURL, CachedThumbnail>()

    func generateThumbnail(for file: File, update updateHandler: @escaping (FileThumbnailRepresentation) -> Void) {
        if let thumbnail = cache.object(forKey: file.url as NSURL)?.thumbnail {
            updateHandler(thumbnail)
        } else {
            generator.generateThumbnail(for: file) { [weak self] thumbnail in
                let cachedThumbnail = CachedThumbnail(thumbnail: thumbnail)
                self?.cache.setObject(cachedThumbnail, forKey: file.url as NSURL)
                updateHandler(thumbnail)
            }
        }
    }
}
