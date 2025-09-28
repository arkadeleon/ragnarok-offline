//
//  FileSystem.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/24.
//

import SwiftUI
import TextEncoding

final class FileSystem: Sendable {
    func canExtractFile(_ file: File) -> Bool {
        switch file.node {
        case .grfArchiveNode(_, let node) where !node.isDirectory:
            true
        default:
            false
        }
    }

    func extractFile(_ file: File) async throws {
        guard case .grfArchiveNode(let grfArchive, let node) = file.node, !node.isDirectory else {
            return
        }

        let contents = try await grfArchive.contentsOfEntryNode(at: node.path)

        let path = node.path.components.map(L2K).joined(separator: "/")
        let url = grfArchive.url.deletingLastPathComponent().appending(path: path)
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
}

extension EnvironmentValues {
    @Entry var fileSystem = FileSystem()
}
