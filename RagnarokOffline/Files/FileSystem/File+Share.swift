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
            file.shareURL ?? file.url
        }
    }

    var canShare: Bool {
        switch node {
        case .directory, .grfDirectory:
            false
        default:
            true
        }
    }

    var shareURL: URL? {
        switch node {
        case .directory, .grfDirectory:
            return nil
        case .regularFile, .grf:
            return url
        case .grfEntry:
            guard let data = contents() else {
                return nil
            }
            do {
                let temporaryURL = FileManager.default.temporaryDirectory.appending(path: name)
                try data.write(to: temporaryURL)
                return temporaryURL
            } catch {
                return nil
            }
        }
    }
}
