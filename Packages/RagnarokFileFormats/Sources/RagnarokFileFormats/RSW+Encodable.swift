//
//  RSW+Encodable.swift
//  RagnarokFileFormats
//
//  Created by Leon Li on 2024/10/16.
//

extension RSW: Encodable {
    enum CodingKeys: String, CodingKey {
        case header
        case version
        case files
        case water
        case light
        case boundingBox
        case models
        case lights
        case sounds
        case effects
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(header, forKey: .header)
        try container.encode(version.description, forKey: .version)
        try container.encode(files, forKey: .files)
        try container.encode(water, forKey: .water)
        try container.encode(light, forKey: .light)
        try container.encode(boundingBox, forKey: .boundingBox)
        try container.encode(models, forKey: .models)
        try container.encode(lights, forKey: .lights)
        try container.encode(sounds, forKey: .sounds)
        try container.encode(effects, forKey: .effects)
    }
}

extension RSW.Files: Encodable {
    enum CodingKeys: String, CodingKey {
        case ini
        case gnd
        case gat
        case src
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ini, forKey: .ini)
        try container.encode(gnd, forKey: .gnd)
        try container.encode(gat, forKey: .gat)
        try container.encode(src, forKey: .src)
    }
}

extension RSW.Water: Encodable {
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

extension RSW.Light: Encodable {
    enum CodingKeys: String, CodingKey {
        case longitude
        case latitude
        case diffuseRed
        case diffuseGreen
        case diffuseBlue
        case ambientRed
        case ambientGreen
        case ambientBlue
        case opacity
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(diffuseRed, forKey: .diffuseRed)
        try container.encode(diffuseGreen, forKey: .diffuseGreen)
        try container.encode(diffuseBlue, forKey: .diffuseBlue)
        try container.encode(ambientRed, forKey: .ambientRed)
        try container.encode(ambientGreen, forKey: .ambientGreen)
        try container.encode(ambientBlue, forKey: .ambientBlue)
        try container.encode(opacity, forKey: .opacity)
    }
}

extension RSW.BoundingBox: Encodable {
    enum CodingKeys: String, CodingKey {
        case top
        case bottom
        case left
        case right
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(top, forKey: .top)
        try container.encode(bottom, forKey: .bottom)
        try container.encode(left, forKey: .left)
        try container.encode(right, forKey: .right)
    }
}

extension RSW.Objects.Model: Encodable {
    enum CodingKeys: String, CodingKey {
        case name
        case animationType
        case animationSpeed
        case blockType
        case modelName
        case nodeName
        case position
        case rotation
        case scale
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(animationType, forKey: .animationType)
        try container.encode(animationSpeed, forKey: .animationSpeed)
        try container.encode(blockType, forKey: .blockType)
        try container.encode(modelName, forKey: .modelName)
        try container.encode(nodeName, forKey: .nodeName)
        try container.encode(position, forKey: .position)
        try container.encode(rotation, forKey: .rotation)
        try container.encode(scale, forKey: .scale)
    }
}

extension RSW.Objects.Light: Encodable {
    enum CodingKeys: String, CodingKey {
        case name
        case position
        case diffuseRed
        case diffuseGreen
        case diffuseBlue
        case range
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(position, forKey: .position)
        try container.encode(diffuseRed, forKey: .diffuseRed)
        try container.encode(diffuseGreen, forKey: .diffuseGreen)
        try container.encode(diffuseBlue, forKey: .diffuseBlue)
        try container.encode(range, forKey: .range)
    }
}

extension RSW.Objects.Sound: Encodable {
    enum CodingKeys: String, CodingKey {
        case name
        case waveName
        case position
        case volume
        case width
        case height
        case range
        case cycle
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(waveName, forKey: .waveName)
        try container.encode(position, forKey: .position)
        try container.encode(volume, forKey: .volume)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
        try container.encode(range, forKey: .range)
        try container.encode(cycle, forKey: .cycle)
    }
}

extension RSW.Objects.Effect: Encodable {
    enum CodingKeys: String, CodingKey {
        case name
        case position
        case id
        case delay
        case parameters
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(position, forKey: .position)
        try container.encode(id, forKey: .id)
        try container.encode(delay, forKey: .delay)
        try container.encode(parameters, forKey: .parameters)
    }
}
