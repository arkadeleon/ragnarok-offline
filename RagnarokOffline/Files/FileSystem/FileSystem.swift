//
//  FileSystem.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/24.
//

import Foundation
import SwiftUI
import TextEncoding

actor FileSystem {
    let thumbnailGenerator = FileThumbnailGenerator()
    var thumbnails: [URL : FileThumbnailPhase] = [:]

    nonisolated func canExtractFile(_ file: File) -> Bool {
        switch file.node {
        case .grfArchiveEntry:
            true
        default:
            false
        }
    }

    nonisolated func extractFile(_ file: File) async throws {
        guard case .grfArchiveEntry(let grfArchive, let entry) = file.node else {
            return
        }

        let contents = try await grfArchive.contentsOfEntry(at: entry.path)

        let path = entry.path.components.map(L2K).joined(separator: "/")
        let url = grfArchive.url.deletingLastPathComponent().appending(path: path)
        let directory = url.deletingLastPathComponent()

        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try contents.write(to: url)
    }

    nonisolated func canDeleteFile(_ file: File) -> Bool {
        switch file.node {
        case .directory, .regularFile, .grfArchive:
            true
        default:
            false
        }
    }

    nonisolated func deleteFile(_ file: File) throws {
        switch file.node {
        case .directory, .regularFile, .grfArchive:
            try FileManager.default.removeItem(at: file.url)
        default:
            break
        }
    }

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
    @Entry var fileSystem = FileSystem()
}
