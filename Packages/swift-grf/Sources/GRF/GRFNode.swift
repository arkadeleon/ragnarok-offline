//
//  GRFNode.swift
//  GRF
//
//  Created by Leon Li on 2025/5/29.
//

public class GRFDirectoryNode: Codable {
    public let subdirectories: [GRFSubdirectoryNode]
    public let entries: [GRFEntryNode]

    init(subdirectories: [GRFSubdirectoryNode], entries: [GRFEntryNode]) {
        self.subdirectories = subdirectories
        self.entries = entries
    }
}

public class GRFSubdirectoryNode: Codable {
    public let path: GRFPath

    init(path: GRFPath) {
        self.path = path
    }
}

public class GRFEntryNode: Codable {
    public let path: GRFPath
    public let size: Int

    init(entry: GRF.Entry) {
        self.path = entry.path
        self.size = Int(entry.size)
    }
}

extension GRFPath: Codable {
    public convenience init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self.init(string: string)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(string)
    }
}
