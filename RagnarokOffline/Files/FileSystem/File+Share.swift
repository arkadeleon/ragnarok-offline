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
        case .regularFile, .grf, .grfEntry:
            true
        case .directory, .grfDirectory:
            false
        }
    }

    func shareURL() async -> URL? {
        switch node {
        case .directory, .grfDirectory:
            return nil
        case .regularFile, .grf:
            return url
        case .grfEntry:
            guard let data = await contents() else {
                return nil
            }
            do {
                let temporaryURL = URL.temporaryDirectory.appending(path: name)
                try data.write(to: temporaryURL)
                return temporaryURL
            } catch {
                logger.warning("\(error.localizedDescription)")
                return nil
            }
        }
    }
}
