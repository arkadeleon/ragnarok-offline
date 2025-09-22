//
//  FileThumbnailPhase.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/9/22.
//

enum FileThumbnailPhase {
    case inProgress(Task<FileThumbnail, any Error>)
    case success(FileThumbnail)
    case failure(any Error)
}
