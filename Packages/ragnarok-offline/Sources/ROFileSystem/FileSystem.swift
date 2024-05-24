//
//  FileSystem.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/24.
//

import Foundation

public class FileSystem {
    public static let shared = FileSystem()

    let cache = NSCache<NSURL, FileThumbnail>()

    public func copy(_ file: File) {
        FilePasteboard.shared.copy(file)
    }

    public func paste(to file: File) -> File? {
        guard let sourceFile = FilePasteboard.shared.file else {
            return nil
        }

        guard case .directory(let url) = file else {
            return nil
        }

        let destinationFile: File = .regularFile(url.appending(path: sourceFile.name))
        switch sourceFile {
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

    public func remove(_ file: File) -> Bool {
        guard case .regularFile(let url) = file else {
            return false
        }

        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch {
            return false
        }
    }

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
