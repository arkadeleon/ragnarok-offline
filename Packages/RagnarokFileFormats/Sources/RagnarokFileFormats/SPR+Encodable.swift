//
//  SPR+Encodable.swift
//  RagnarokFileFormats
//
//  Created by Leon Li on 2024/10/16.
//

extension SPR: Encodable {
    enum CodingKeys: String, CodingKey {
        case header
        case version
        case sprites
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(header, forKey: .header)
        try container.encode(version.description, forKey: .version)
        try container.encode(sprites, forKey: .sprites)
    }
}

extension SPR.Sprite: Encodable {
    enum CodingKeys: String, CodingKey {
        case type
        case width
        case height
        case data
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type.rawValue, forKey: .type)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
        try container.encode(data, forKey: .data)
    }
}
