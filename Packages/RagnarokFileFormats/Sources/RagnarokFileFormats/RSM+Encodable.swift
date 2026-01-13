//
//  RSM+Encodable.swift
//  RagnarokFileFormats
//
//  Created by Leon Li on 2024/10/16.
//

extension RSM: Encodable {
    enum CodingKeys: String, CodingKey {
        case header
        case version
        case animationLength
        case shadeType
        case alpha
        case rootNodes
        case nodes
        case scaleKeyframes
        case volumeBoxes
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(header, forKey: .header)
        try container.encode(version.description, forKey: .version)
        try container.encode(animationLength, forKey: .animationLength)
        try container.encode(shadeType, forKey: .shadeType)
        try container.encode(alpha, forKey: .alpha)
        try container.encode(rootNodes, forKey: .rootNodes)
        try container.encode(nodes, forKey: .nodes)
        try container.encode(scaleKeyframes, forKey: .scaleKeyframes)
        try container.encode(volumeBoxes, forKey: .volumeBoxes)
    }
}

extension RSM.Node: Encodable {
    enum CodingKeys: String, CodingKey {
        case name
        case parentName
        case textures
        case transformMatrix
        case offset
        case position
        case rotationAngle
        case rotationAxis
        case scale
        case vertices
        case tvertices
        case faces
        case scaleKeyframes
        case rotationKeyframes
        case positionKeyframes
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(parentName, forKey: .parentName)
        try container.encode(textures, forKey: .textures)
        try container.encode([transformMatrix.columns.0, transformMatrix.columns.1, transformMatrix.columns.2], forKey: .transformMatrix)
        try container.encode(offset, forKey: .offset)
        try container.encode(position, forKey: .position)
        try container.encode(rotationAngle, forKey: .rotationAngle)
        try container.encode(rotationAxis, forKey: .rotationAxis)
        try container.encode(scale, forKey: .scale)
        try container.encode(vertices, forKey: .vertices)
        try container.encode(tvertices, forKey: .tvertices)
        try container.encode(faces, forKey: .faces)
        try container.encode(scaleKeyframes, forKey: .scaleKeyframes)
        try container.encode(rotationKeyframes, forKey: .rotationKeyframes)
        try container.encode(positionKeyframes, forKey: .positionKeyframes)
    }
}

extension RSM.Node.TextureVertex: Encodable {
    enum CodingKeys: String, CodingKey {
        case color
        case u
        case v
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(color, forKey: .color)
        try container.encode(u, forKey: .u)
        try container.encode(v, forKey: .v)
    }
}

extension RSM.Face: Encodable {
    enum CodingKeys: String, CodingKey {
        case vertexIndices
        case tvertexIndices
        case textureIndex
        case padding
        case twoSided
        case smoothGroup
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(vertexIndices, forKey: .vertexIndices)
        try container.encode(tvertexIndices, forKey: .tvertexIndices)
        try container.encode(textureIndex, forKey: .textureIndex)
        try container.encode(padding, forKey: .padding)
        try container.encode(twoSided, forKey: .twoSided)
        try container.encode(smoothGroup, forKey: .smoothGroup)
    }
}

extension RSM.ScaleKeyframe: Encodable {
    enum CodingKeys: String, CodingKey {
        case frame
        case scale
        case data
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(frame, forKey: .frame)
        try container.encode(scale, forKey: .scale)
        try container.encode(data, forKey: .data)
    }
}

extension RSM.RotationKeyframe: Encodable {
    enum CodingKeys: String, CodingKey {
        case frame
        case quaternion
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(frame, forKey: .frame)
        try container.encode(quaternion.vector, forKey: .quaternion)
    }
}

extension RSM.PositionKeyframe: Encodable {
    enum CodingKeys: String, CodingKey {
        case frame
        case position
        case data
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(frame, forKey: .frame)
        try container.encode(position, forKey: .position)
        try container.encode(data, forKey: .data)
    }
}

extension RSM.VolumeBox: Encodable {
    enum CodingKeys: String, CodingKey {
        case size
        case position
        case rotation
        case flag
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(size, forKey: .size)
        try container.encode(position, forKey: .position)
        try container.encode(rotation, forKey: .rotation)
        try container.encode(flag, forKey: .flag)
    }
}
