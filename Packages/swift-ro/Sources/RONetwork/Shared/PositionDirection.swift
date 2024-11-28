//
//  PositionDirection.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/11/27.
//

public struct PositionDirection {
    public var x: UInt16
    public var y: UInt16
    public var direction: UInt8

    public init(data: [UInt8]) {
        var p: UInt32 = 0
        withUnsafeMutableBytes(of: &p) { pointer in
            pointer[2] = data[0]
            pointer[1] = data[1]
            pointer[0] = data[2]
        }

        direction = UInt8(truncatingIfNeeded: p) & 0x0f

        p = p >> 4
        y = UInt16(truncatingIfNeeded: p) & 0x03ff

        p = p >> 10
        x = UInt16(truncatingIfNeeded: p) & 0x03ff
    }
}
