//
//  AmbientColor.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/7.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

struct AmbientColor: Encodable {
    var red: Float
    var green: Float
    var blue: Float

    init(red: Float, green: Float, blue: Float) {
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
