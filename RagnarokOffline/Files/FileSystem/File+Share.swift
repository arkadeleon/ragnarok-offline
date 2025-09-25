//
//  File+Share.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/2/28.
//

import CoreTransferable

extension File: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation { file in
            let url = await file.shareURL() ?? file.url
            return url
        }
    }

    var canShare: Bool {
        switch node {
        case .regularFile, .grfArchive:
            true
        case .directory:
            false
        case .grfArchiveNode(_, let node):
            !node.isDirectory
        }
    }

    func shareURL() async -> URL? {
        switch node {
        case .directory:
            return nil
        case .regularFile, .grfArchive:
            return url
        case .grfArchiveNode:
            guard let data = try? await contents() else {
                return nil
            }
            do {
                let temporaryURL = URL.temporaryDirectory.appending(path: name)
                try data.write(to: temporaryURL)
                return temporaryURL
            } catch {
                logger.warning("\(error)")
                return nil
            }
        }
    }
}
