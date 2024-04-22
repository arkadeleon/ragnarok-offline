//
//  Color.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/7.
//

import ROStream

public struct Color: Equatable, Encodable {
    public var red: UInt8
    public var green: UInt8
    public var blue: UInt8
    public var alpha: UInt8

    public init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    init(from reader: BinaryReader) throws {
        red = try reader.readInt()
        green = try reader.readInt()
        blue = try reader.readInt()
        alpha = try reader.readInt()
    }
}
