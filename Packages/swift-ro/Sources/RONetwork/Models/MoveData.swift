//
//  MoveData.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/24.
//

// See `WBUFPOS2`
struct MoveData {
    let x0: Int16
    let y0: Int16
    let x1: Int16
    let y1: Int16
    let sx0: UInt8
    let sy0: UInt8

    init(data: [UInt8]) {
        let a = data[0]
        let b = data[1]
        let c = data[2]
        let d = data[3]
        let e = data[4]
        let f = data[5]

        self.x0 = ((Int16(a) & 0xff) << 2) | ((Int16(b) & 0xc0) >> 6)
        self.y0 = ((Int16(b) & 0x3f) << 4) | ((Int16(c) & 0xf0) >> 4)
        self.x1 = ((Int16(d) & 0xfc) >> 2) | ((Int16(c) & 0x0f) << 6)
        self.y1 = ((Int16(d) & 0x03) << 8) | ((Int16(e) & 0xff))
        self.sx0 = ((f & 0xf0) >> 4)
        self.sy0 = ((f & 0x0f))
    }
}
