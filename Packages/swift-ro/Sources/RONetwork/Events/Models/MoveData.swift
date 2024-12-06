//
//  MoveData.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/24.
//

// See `WBUFPOS2`
struct MoveData {
    var x0: Int16
    var y0: Int16
    var x1: Int16
    var y1: Int16
    var sx0: UInt8
    var sy0: UInt8

    init(data: [UInt8]) {
        let a = data[0]
        let b = data[1]
        let c = data[2]
        let d = data[3]
        let e = data[4]
        let f = data[5]

        x0 = ((Int16(a) & 0xff) << 2) | ((Int16(b) & 0xc0) >> 6)
        y0 = ((Int16(b) & 0x3f) << 4) | ((Int16(c) & 0xf0) >> 4)
        x1 = ((Int16(d) & 0xfc) >> 2) | ((Int16(c) & 0x0f) << 6)
        y1 = ((Int16(d) & 0x03) << 8) | ((Int16(e) & 0xff))
        sx0 = ((f & 0xf0) >> 4)
        sy0 = ((f & 0x0f))
    }
}
