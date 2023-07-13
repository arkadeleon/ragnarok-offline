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
}
