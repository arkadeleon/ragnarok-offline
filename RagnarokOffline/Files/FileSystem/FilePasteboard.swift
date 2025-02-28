//
//  FilePasteboard.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/27.
//

import Foundation

class FilePasteboard {
    static let shared = FilePasteboard()

    var file: File?
    var hasFile = false

    func copy(_ file: File) {
        self.file = file
        hasFile = true
    }
}
