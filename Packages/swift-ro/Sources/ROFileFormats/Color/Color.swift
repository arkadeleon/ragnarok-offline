//
//  Color.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/7.
//

import ROCore

public struct Color: BinaryDecodable, Equatable, Sendable {
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

    public init(from decoder: BinaryDecoder) throws {
        red = try decoder.decode(UInt8.self)
        green = try decoder.decode(UInt8.self)
        blue = try decoder.decode(UInt8.self)
        alpha = try decoder.decode(UInt8.self)
    }
}
