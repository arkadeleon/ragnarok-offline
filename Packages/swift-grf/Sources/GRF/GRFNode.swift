//
//  GRFNode.swift
//  GRF
//
//  Created by Leon Li on 2025/5/29.
//

final public class GRFDirectoryNode: Sendable {
    public let subdirectories: [GRFSubdirectoryNode]
    public let entries: [GRFEntryNode]

    init(subdirectories: [GRFSubdirectoryNode], entries: [GRFEntryNode]) {
        self.subdirectories = subdirectories
        self.entries = entries
    }
}

final public class GRFSubdirectoryNode: Sendable {
    public let path: GRFPath

    init(path: GRFPath) {
        self.path = path
    }
}

final public class GRFEntryNode: Sendable {
    public let path: GRFPath
    public let size: Int

    init(entry: GRF.Entry) {
        self.path = entry.path
        self.size = Int(entry.size)
    }
}
