//
//  FileSystem.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/24.
//

import SwiftUI

final class FileSystem: Sendable {
    private let fileExtractor = FileExtractor()

    func canExtractFile(_ file: File) -> Bool {
        guard file.location == .client else {
            return false
        }

        switch file.node {
        case .grfArchiveNode:
            return true
        default:
            return false
        }
    }

    func extractFile(_ file: File) async throws {
        try await fileExtractor.extract(file)
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
