//
//  FileSystem.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/24.
//

import Foundation
import ROCore
import ROResources

class FileSystem {
    static let shared = FileSystem()

    let thumbnailGenerator = FileThumbnailGenerator()
    let thumbnailCache = NSCache<NSURL, FileThumbnail>()

    func canExtractFile(_ file: File) -> Bool {
        switch file.node {
        case .grfArchiveEntry:
            true
        default:
            false
        }
    }

    func extractFile(_ file: File) async throws {
        guard case .grfArchiveEntry(let grfArchive, let entry) = file.node else {
            return
        }

        let contents = try await grfArchive.contentsOfEntry(at: entry.path)

        let path = entry.path.components.map(L2K).joined(separator: "/")
        let url = ResourceManager.shared.localURL.appending(path: path)
        let directory = url.deletingLastPathComponent()

        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try contents.write(to: url)
    }

    func canDeleteFile(_ file: File) -> Bool {
        switch file.node {
        case .directory, .regularFile, .grfArchive:
            true
        default:
            false
        }
    }

    func deleteFile(_ file: File) throws {
        switch file.node {
        case .directory, .regularFile, .grfArchive:
            try FileManager.default.removeItem(at: file.url)
        default:
            break
        }
    }

    func thumbnail(for request: FileThumbnailRequest) async throws -> FileThumbnail? {
        try Task.checkCancellation()

        if let thumbnail = thumbnailCache.object(forKey: request.file.url as NSURL) {
            return thumbnail
        }

        try Task.checkCancellation()

        let thumbnail = try await thumbnailGenerator.generateThumbnail(for: request)

        if let thumbnail {
            thumbnailCache.setObject(thumbnail, forKey: request.file.url as NSURL)
        }

        try Task.checkCancellation()

        return thumbnail
    }
}
