//
//  GRFNode.swift
//  GRF
//
//  Created by Leon Li on 2025/5/29.
//

public struct GRFNode: Sendable {
    public let path: GRFPath
    public let isDirectory: Bool

    init(path: GRFPathReference, isDirectory: Bool) {
        self.path = GRFPath(path: path)
        self.isDirectory = isDirectory
    }
}
