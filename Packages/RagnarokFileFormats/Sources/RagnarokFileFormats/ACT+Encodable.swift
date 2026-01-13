//
//  ACT+Encodable.swift
//  RagnarokFileFormats
//
//  Created by Leon Li on 2024/10/15.
//

extension ACT: Encodable {
    enum CodingKeys: String, CodingKey {
        case header
        case version
        case actions
        case sounds
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(header, forKey: .header)
        try container.encode(version.description, forKey: .version)
        try container.encode(actions, forKey: .actions)
        try container.encode(sounds, forKey: .sounds)
    }
}

extension ACT.Action: Encodable {
    enum CodingKeys: String, CodingKey {
        case frames
        case animationSpeed
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(frames, forKey: .frames)
        try container.encode(animationSpeed, forKey: .animationSpeed)
    }
}

extension ACT.Frame: Encodable {
    enum CodingKeys: String, CodingKey {
        case layers
        case soundIndex
        case anchorPoints
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(layers, forKey: .layers)
        try container.encode(soundIndex, forKey: .soundIndex)
        try container.encode(anchorPoints, forKey: .anchorPoints)
    }
}

extension ACT.Layer: Encodable {
    enum CodingKeys: String, CodingKey {
        case offset
        case spriteIndex
        case isMirrored
        case color
        case scale
        case rotationAngle
        case spriteType
        case width
        case height
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(offset, forKey: .offset)
        try container.encode(spriteIndex, forKey: .spriteIndex)
        try container.encode(isMirrored, forKey: .isMirrored)
        try container.encode(color, forKey: .color)
        try container.encode(scale, forKey: .scale)
        try container.encode(rotationAngle, forKey: .rotationAngle)
        try container.encode(spriteType, forKey: .spriteType)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
    }
}

extension ACT.AnchorPoint: Encodable {
    enum CodingKeys: String, CodingKey {
        case x
        case y
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
    }
}
