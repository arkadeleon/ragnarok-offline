//
//  DocumentThumbnailCache.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/24.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import Foundation

class DocumentThumbnailCache {

    private class CachedThumbnail {
        let thumbnail: DocumentThumbnailRepresentation

        init(thumbnail: DocumentThumbnailRepresentation) {
            self.thumbnail = thumbnail
        }
    }

    static let shared = DocumentThumbnailCache()

    private let generator = DocumentThumbnailGenerator()
    private let cache = NSCache<NSURL, CachedThumbnail>()

    func generateThumbnail(for document: DocumentWrapper, update updateHandler: @escaping (DocumentThumbnailRepresentation) -> Void) {
        if let thumbnail = cache.object(forKey: document.id as NSURL)?.thumbnail {
            updateHandler(thumbnail)
        } else {
            generator.generateThumbnail(for: document) { [weak self] thumbnail in
                let cachedThumbnail = CachedThumbnail(thumbnail: thumbnail)
                self?.cache.setObject(cachedThumbnail, forKey: document.id as NSURL)
                updateHandler(thumbnail)
            }
        }
    }
}
