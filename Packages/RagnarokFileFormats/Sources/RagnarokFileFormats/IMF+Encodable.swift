//
//  IMF+Encodable.swift
//  RagnarokFileFormats
//
//  Created by Leon Li on 2025/3/14.
//

extension IMF: Encodable {
    enum CodingKeys: String, CodingKey {
        case version
        case checksum
        case layers
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version.description, forKey: .version)
        try container.encode(checksum, forKey: .checksum)
        try container.encode(layers, forKey: .layers)
    }
}

extension IMF.Layer: Encodable {
    enum CodingKeys: String, CodingKey {
        case actions
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(actions, forKey: .actions)
    }
}

extension IMF.Action: Encodable {
    enum CodingKeys: String, CodingKey {
        case frames
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(frames, forKey: .frames)
    }
}

extension IMF.Frame: Encodable {
    enum CodingKeys: String, CodingKey {
        case priority
        case cx
        case cy
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(priority, forKey: .priority)
        try container.encode(cx, forKey: .cx)
        try container.encode(cy, forKey: .cy)
    }
}
