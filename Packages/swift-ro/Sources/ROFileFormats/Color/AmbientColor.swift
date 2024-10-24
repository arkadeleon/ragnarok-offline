//
//  AmbientColor.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/7.
//

import ROCore

public struct AmbientColor {
    public var red: Float
    public var green: Float
    public var blue: Float

    public init(red: Float, green: Float, blue: Float) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    init(from reader: BinaryReader) throws {
        red = try reader.readFloat()
        green = try reader.readFloat()
        blue = try reader.readFloat()
    }
}
