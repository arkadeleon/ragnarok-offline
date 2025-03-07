//
//  FileSystem.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/24.
//

import Foundation

actor FileSystem {
    static let shared = FileSystem()

    let thumbnailGenerator = FileThumbnailGenerator()
    let thumbnailCache = NSCache<NSURL, FileThumbnail>()

    nonisolated func copy(_ file: File) {
        FilePasteboard.shared.copy(file)
    }

    nonisolated func paste(to file: File) -> File? {
        guard let sourceFile = FilePasteboard.shared.file else {
            return nil
        }

        guard case .directory(let url) = file.node else {
            return nil
        }

        let destinationFile = File(node: .regularFile(url.appending(path: sourceFile.name)))
        switch sourceFile.node {
        case.directory:
            return nil
        case .regularFile:
            do {
                try FileManager.default.copyItem(at: sourceFile.url, to: destinationFile.url)
                return destinationFile
            } catch {
                return nil
            }
        case .grf:
            return nil
        case .grfDirectory:
            return nil
        case .grfEntry(let grf, let path):
            guard let contents = try? grf.contentsOfEntry(at: path) else {
                return nil
            }
            do {
                try contents.write(to: destinationFile.url)
                return destinationFile
            } catch {
                return nil
            }
        }
    }

    nonisolated func remove(_ file: File) -> Bool {
        guard case .regularFile(let url) = file.node else {
            return false
        }

        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch {
            return false
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
