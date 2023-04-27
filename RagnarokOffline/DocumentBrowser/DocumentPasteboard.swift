//
//  DocumentPasteboard.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/27.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import Foundation

class DocumentPasteboard: ObservableObject {

    @Published var document: DocumentWrapper?
    @Published var hasDocument = false

    func copy(_ document: DocumentWrapper) {
        self.document = document
        hasDocument = true
    }

    func paste(into directory: URL) {
        guard let document else {
            return
        }

        let destination = directory.appending(path: document.name)
        switch document {
        case .url(let url):
            try? FileManager.default.copyItem(at: url, to: destination)
        case .grf:
            break
        case .grfNode(_, let node):
            if let contents = node.contents {
                try? contents.write(to: destination)
            }
        }
    }
}
