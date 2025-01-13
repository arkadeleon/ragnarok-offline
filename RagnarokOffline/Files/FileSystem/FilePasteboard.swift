//
//  FilePasteboard.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/27.
//

import Foundation

public class FilePasteboard {
    public static let shared = FilePasteboard()

    public var file: File?
    public var hasFile = false

    public func copy(_ file: File) {
        self.file = file
        hasFile = true
    }
}
