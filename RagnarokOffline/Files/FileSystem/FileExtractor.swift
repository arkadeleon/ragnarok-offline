//
//  FileExtractor.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/5/11.
//

import Foundation
import GRF
import RagnarokCore

actor FileExtractor {
    func extract(_ file: File) async throws {
        guard file.location == .client else {
            return
        }

        guard case .grfArchiveNode(let grfArchive, let node) = file.node else {
            return
        }

        if node.isDirectory {
            let directoryURL = destinationURL(for: node, in: grfArchive)
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            try await extractDirectoryNode(node, from: grfArchive)
        } else {
            try await extractEntryNode(node, from: grfArchive)
        }
    }

    private func extractDirectoryNode(_ node: GRFNode, from grfArchive: GRFArchive) async throws {
        let children = await grfArchive.childrenOfDirectoryNode(at: node.path)

        for child in children {
            try Task.checkCancellation()

            if child.isDirectory {
                let directoryURL = destinationURL(for: child, in: grfArchive)
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
                try await extractDirectoryNode(child, from: grfArchive)
            } else {
                try await extractEntryNode(child, from: grfArchive)
            }
        }
    }

    private func extractEntryNode(_ node: GRFNode, from grfArchive: GRFArchive) async throws {
        let contents = try await grfArchive.contentsOfEntryNode(at: node.path)

        let url = destinationURL(for: node, in: grfArchive)
        let directory = url.deletingLastPathComponent()

        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try contents.write(to: url)
    }

    private func destinationURL(for node: GRFNode, in grfArchive: GRFArchive) -> URL {
        let path = node.path.components.map(L2K).joined(separator: "/")
        return grfArchive.url.deletingLastPathComponent().appending(path: path)
    }
}
