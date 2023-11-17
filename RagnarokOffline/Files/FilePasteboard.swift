//
//  FilePasteboard.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/27.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

class FilePasteboard {
    static let shared = FilePasteboard()

    var file: File?
    var hasFile = false

    func copy(_ file: File) {
        self.file = file
        hasFile = true
    }
}
