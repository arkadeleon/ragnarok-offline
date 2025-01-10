//
//  DiffuseColor.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/7.
//

import ROCore

public struct DiffuseColor: BinaryDecodable, Sendable {
    public var red: Float
    public var green: Float
    public var blue: Float

    public init(red: Float, green: Float, blue: Float) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    public init(from decoder: BinaryDecoder) throws {
        red = try decoder.decode(Float.self)
        green = try decoder.decode(Float.self)
        blue = try decoder.decode(Float.self)
    }
}
