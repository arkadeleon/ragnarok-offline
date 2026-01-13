//
//  GAT+Encodable.swift
//  RagnarokFileFormats
//
//  Created by Leon Li on 2024/10/15.
//

extension GAT: Encodable {
    enum CodingKeys: String, CodingKey {
        case header
        case version
        case width
        case height
        case tiles
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(header, forKey: .header)
        try container.encode(version.description, forKey: .version)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
        try container.encode(tiles, forKey: .tiles)
    }
}

extension GAT.Tile: Encodable {
    enum CodingKeys: String, CodingKey {
        case bottomLeftAltitude
        case bottomRightAltitude
        case topLeftAltitude
        case topRightAltitude
        case type
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bottomLeftAltitude, forKey: .bottomLeftAltitude)
        try container.encode(bottomRightAltitude, forKey: .bottomRightAltitude)
        try container.encode(topLeftAltitude, forKey: .topLeftAltitude)
        try container.encode(topRightAltitude, forKey: .topRightAltitude)
        try container.encode(type.rawValue, forKey: .type)
    }
}
