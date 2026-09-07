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
        case water
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
        try container.encodeIfPresent(water, forKey: .water)
    }
}

extension GND.Lightmap: Encodable {
    enum CodingKeys: String, CodingKey {
        case sliceCount
        case sliceWidth
        case sliceHeight
        case pixelFormat
        case shadowmapPixels
        case lightmapPixels
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sliceCount, forKey: .sliceCount)
        try container.encode(sliceWidth, forKey: .sliceWidth)
        try container.encode(sliceHeight, forKey: .sliceHeight)
        try container.encode(pixelFormat, forKey: .pixelFormat)
        try container.encode(shadowmapPixels, forKey: .shadowmapPixels)
        try container.encode(lightmapPixels, forKey: .lightmapPixels)
    }
}

extension GND.Lightmap.LightmapPixel: Encodable {
    enum CodingKeys: String, CodingKey {
        case red
        case green
        case blue
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(red, forKey: .red)
        try container.encode(green, forKey: .green)
        try container.encode(blue, forKey: .blue)
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

extension GND.Water: Encodable {
    enum CodingKeys: String, CodingKey {
        case level
        case type
        case waveHeight
        case waveSpeed
        case wavePitch
        case animationSpeed
        case splitWidth
        case splitHeight
        case zones
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(level, forKey: .level)
        try container.encode(type, forKey: .type)
        try container.encode(waveHeight, forKey: .waveHeight)
        try container.encode(waveSpeed, forKey: .waveSpeed)
        try container.encode(wavePitch, forKey: .wavePitch)
        try container.encode(animationSpeed, forKey: .animationSpeed)
        try container.encode(splitWidth, forKey: .splitWidth)
        try container.encode(splitHeight, forKey: .splitHeight)
        try container.encode(zones, forKey: .zones)
    }
}

extension GND.Water.Zone: Encodable {
    enum CodingKeys: String, CodingKey {
        case level
        case type
        case waveHeight
        case waveSpeed
        case wavePitch
        case animationSpeed
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(level, forKey: .level)
        try container.encode(type, forKey: .type)
        try container.encode(waveHeight, forKey: .waveHeight)
        try container.encode(waveSpeed, forKey: .waveSpeed)
        try container.encode(wavePitch, forKey: .wavePitch)
        try container.encode(animationSpeed, forKey: .animationSpeed)
    }
}
