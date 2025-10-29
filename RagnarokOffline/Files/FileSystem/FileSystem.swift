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
        guard file.location == .client else {
            return false
        }

        switch file.node {
        case .grfArchiveNode(_, let node) where !node.isDirectory:
            return true
        default:
            return false
        }
    }

    func extractFile(_ file: File) async throws {
        guard file.location == .client else {
            return
        }

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
        guard file.location == .client else {
            return false
        }

        switch file.node {
        case .directory, .regularFile, .grfArchive:
            return true
        default:
            return false
        }
    }

    func deleteFile(_ file: File) throws {
        guard file.location == .client else {
            return
        }

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
