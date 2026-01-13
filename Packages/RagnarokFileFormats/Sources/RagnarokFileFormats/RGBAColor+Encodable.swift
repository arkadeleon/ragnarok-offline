//
//  RGBAColor+Encodable.swift
//  RagnarokFileFormats
//
//  Created by Leon Li on 2024/10/16.
//

extension RGBAColor: Encodable {
    enum CodingKeys: String, CodingKey {
        case red
        case green
        case blue
        case alpha
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(red, forKey: .red)
        try container.encode(green, forKey: .green)
        try container.encode(blue, forKey: .blue)
        try container.encode(alpha, forKey: .alpha)
    }
}
