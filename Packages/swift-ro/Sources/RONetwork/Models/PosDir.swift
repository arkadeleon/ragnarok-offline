//
//  PosDir.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/27.
//

// See `WBUFPOS`
struct PosDir {
    var x: Int16
    var y: Int16
    var dir: UInt8

    init(data: [UInt8]) {
        var p: UInt32 = 0
        withUnsafeMutableBytes(of: &p) { pointer in
            pointer[2] = data[0]
            pointer[1] = data[1]
            pointer[0] = data[2]
        }

        dir = UInt8(truncatingIfNeeded: p) & 0x0f

        p = p >> 4
        y = Int16(truncatingIfNeeded: p) & 0x03ff

        p = p >> 10
        x = Int16(truncatingIfNeeded: p) & 0x03ff
    }
}