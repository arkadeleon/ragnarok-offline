//
//  RGBAColor.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/7.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

struct RGBAColor: Equatable, Encodable {
    var red: UInt8
    var green: UInt8
    var blue: UInt8
    var alpha: UInt8

    init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
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
