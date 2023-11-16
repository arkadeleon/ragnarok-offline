//
//  FilePasteboard.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/27.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import Foundation

class FilePasteboard: ObservableObject {

    @Published var file: File?
    @Published var hasFile = false

    func copy(_ file: File) {
        self.file = file
        hasFile = true
    }
}
