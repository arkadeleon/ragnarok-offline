//
//  FileThumbnailCache.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/9/28.
//

import Foundation
import SwiftUI

enum FileThumbnailPhase {
    case inProgress(Task<FileThumbnail, any Error>)
    case success(FileThumbnail)
    case failure(any Error)
}

actor FileThumbnailCache {
    let thumbnailGenerator = FileThumbnailGenerator()
    var thumbnails: [URL : FileThumbnailPhase] = [:]

    func thumbnail(for request: FileThumbnailRequest) async throws -> FileThumbnail {
        if let phase = thumbnails[request.file.url] {
            switch phase {
            case .inProgress(let task):
                return try await task.value
            case .success(let thumbnail):
                return thumbnail
            case .failure(let error):
                throw error
            }
        }

        let task = Task {
            try await thumbnailGenerator.generateThumbnail(for: request)
        }

        thumbnails[request.file.url] = .inProgress(task)

        do {
            let thumbnail = try await task.value
            thumbnails[request.file.url] = .success(thumbnail)

            return thumbnail
        } catch {
            thumbnails[request.file.url] = .failure(error)

            throw error
        }
    }
}

extension EnvironmentValues {
    @Entry var fileThumbnailCache = FileThumbnailCache()
}
