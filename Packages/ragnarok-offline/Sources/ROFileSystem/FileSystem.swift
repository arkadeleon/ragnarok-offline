//
//  FileSystem.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/24.
//

import Foundation

public actor FileSystem {
    public static let shared = FileSystem()

    let cache = NSCache<NSURL, FileThumbnail>()

    public func thumbnail(for request: FileThumbnailRequest) async throws -> FileThumbnail? {
        try Task.checkCancellation()

        if let thumbnail = cache.object(forKey: request.file.url as NSURL) {
            return thumbnail
        }

        try Task.checkCancellation()

        let thumbnail = try await FileThumbnailGenerator.shared.generateThumbnail(for: request)

        if let thumbnail {
            cache.setObject(thumbnail, forKey: request.file.url as NSURL)
        }

        try Task.checkCancellation()

        return thumbnail
    }
}
