//
//  MoveData.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/24.
//

public struct MoveData: Sendable {
    public var x0: UInt16
    public var y0: UInt16
    public var x1: UInt16
    public var y1: UInt16
    public var sx0: UInt8
    public var sy0: UInt8

    public init(data: [UInt8]) {
        let a = data[0]
        let b = data[1]
        let c = data[2]
        let d = data[3]
        let e = data[4]
        let f = data[5]

        x0 = ((UInt16(a) & 0xFF) << 2) | ((UInt16(b) & 0xc0) >> 6)
        y0 = ((UInt16(b) & 0x3F) << 4) | ((UInt16(c) & 0xF0) >> 4)
        x1 = ((UInt16(d) & 0xFC) >> 2) | ((UInt16(c) & 0x0F) << 6)
        y1 = ((UInt16(d) & 0x03) << 8) | ((UInt16(e) & 0xFF))
        sx0 = ((f & 0xF0) >> 4)
        sy0 = ((f & 0xF))
    }
}
