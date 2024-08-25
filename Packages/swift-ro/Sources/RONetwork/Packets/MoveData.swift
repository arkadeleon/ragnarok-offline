//
//  MoveData.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/24.
//

public struct MoveData: BinaryDecodable {
    public var x0: Int16
    public var y0: Int16
    public var x1: Int16
    public var y1: Int16
    public var sx0: UInt8
    public var sy0: UInt8

    public init(from decoder: BinaryDecoder) throws {
        let a = try decoder.decode(Int8.self)
        let b = try decoder.decode(Int8.self)
        let c = try decoder.decode(Int8.self)
        let d = try decoder.decode(Int8.self)
        let e = try decoder.decode(Int8.self)
        let f = try decoder.decode(UInt8.self)

        x0 = ((Int16(a) & 0xff) << 2) | ((Int16(b) & 0xc0) >> 6)
        y0 = ((Int16(b) & 0x3F) << 4) | ((Int16(c) & 0xF0) >> 4)
        x1 = ((Int16(d) & 0xFC) >> 2) | ((Int16(c) & 0x0F) << 6)
        y1 = ((Int16(d) & 0x03) << 8) | ((Int16(e) & 0xFF))
        sx0 = ((f & 0xF0) >> 4)
        sy0 = ((f & 0xF))
    }
}
