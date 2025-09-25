//
//  GRFNode.swift
//  GRF
//
//  Created by Leon Li on 2025/5/29.
//

final public class GRFNode: Sendable {
    public let path: GRFPath
    public let isDirectory: Bool

    init(path: GRFPath, isDirectory: Bool) {
        self.path = path
        self.isDirectory = isDirectory
    }
}
