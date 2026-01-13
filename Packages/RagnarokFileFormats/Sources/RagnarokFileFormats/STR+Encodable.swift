//
//  STR+Encodable.swift
//  RagnarokFileFormats
//
//  Created by Leon Li on 2024/10/16.
//

extension STR: Encodable {
    enum CodingKeys: String, CodingKey {
        case header
        case version
        case fps
        case maxKeyframeIndex
        case layers
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(header, forKey: .header)
        try container.encode(version.description, forKey: .version)
        try container.encode(fps, forKey: .fps)
        try container.encode(maxKeyframeIndex, forKey: .maxKeyframeIndex)
        try container.encode(layers, forKey: .layers)
    }
}

extension STR.Layer: Encodable {
    enum CodingKeys: String, CodingKey {
        case textures
        case keyframes
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(textures, forKey: .textures)
        try container.encode(keyframes, forKey: .keyframes)
    }
}

extension STR.Keyframe: Encodable {
    enum CodingKeys: String, CodingKey {
        case frameIndex
        case type
        case position
        case uv
        case xy
        case textureIndex
        case animationType
        case delay
        case angle
        case color
        case sourceAlpha
        case destinationAlpha
        case multiTexturePreset
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(frameIndex, forKey: .frameIndex)
        try container.encode(type, forKey: .type)
        try container.encode(position, forKey: .position)
        try container.encode(uv, forKey: .uv)
        try container.encode(xy, forKey: .xy)
        try container.encode(textureIndex, forKey: .textureIndex)
        try container.encode(animationType, forKey: .animationType)
        try container.encode(delay, forKey: .delay)
        try container.encode(angle, forKey: .angle)
        try container.encode(color, forKey: .color)
        try container.encode(sourceAlpha, forKey: .sourceAlpha)
        try container.encode(destinationAlpha, forKey: .destinationAlpha)
        try container.encode(multiTexturePreset, forKey: .multiTexturePreset)
    }
}
