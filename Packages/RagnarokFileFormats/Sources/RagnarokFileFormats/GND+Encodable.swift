//
//  GND+Encodable.swift
//  RagnarokFileFormats
//
//  Created by Leon Li on 2024/10/16.
//

extension GND: Encodable {
    enum CodingKeys: String, CodingKey {
        case header
        case version
        case width
        case height
        case zoom
        case textures
        case lightmap
        case surfaces
        case cubes
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(header, forKey: .header)
        try container.encode(version.description, forKey: .version)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
        try container.encode(zoom, forKey: .zoom)
        try container.encode(textures, forKey: .textures)
        try container.encode(lightmap, forKey: .lightmap)
        try container.encode(surfaces, forKey: .surfaces)
        try container.encode(cubes, forKey: .cubes)
    }
}

extension GND.Lightmap: Encodable {
    enum CodingKeys: String, CodingKey {
        case per_cell
        case count
        case data
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(per_cell, forKey: .per_cell)
        try container.encode(count, forKey: .count)
        try container.encode(data, forKey: .data)
    }
}

extension GND.Surface: Encodable {
    enum CodingKeys: String, CodingKey {
        case u
        case v
        case textureIndex
        case lightmapIndex
        case color
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(u, forKey: .u)
        try container.encode(v, forKey: .v)
        try container.encode(textureIndex, forKey: .textureIndex)
        try container.encode(lightmapIndex, forKey: .lightmapIndex)
        try container.encode(color, forKey: .color)
    }
}

extension GND.Cube: Encodable {
    enum CodingKeys: String, CodingKey {
        case bottomLeftAltitude
        case bottomRightAltitude
        case topLeftAltitude
        case topRightAltitude
        case topSurfaceIndex
        case frontSurfaceIndex
        case rightSurfaceIndex
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bottomLeftAltitude, forKey: .bottomLeftAltitude)
        try container.encode(bottomRightAltitude, forKey: .bottomRightAltitude)
        try container.encode(topLeftAltitude, forKey: .topLeftAltitude)
        try container.encode(topRightAltitude, forKey: .topRightAltitude)
        try container.encode(topSurfaceIndex, forKey: .topSurfaceIndex)
        try container.encode(frontSurfaceIndex, forKey: .frontSurfaceIndex)
        try container.encode(rightSurfaceIndex, forKey: .rightSurfaceIndex)
    }
}
