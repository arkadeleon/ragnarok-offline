//
//  PACKET_ZC_STATUS.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/29.
//

import ROCore

/// See `clif_initialstatus`
public struct PACKET_ZC_STATUS: DecodablePacket {
    public static var packetType: Int16 {
        0xbd
    }

    public var packetLength: Int16 {
        44
    }

    public var statusPoint: UInt16
    public var str: UInt8
    public var needStr: UInt8
    public var agi: UInt8
    public var needAgi: UInt8
    public var vit: UInt8
    public var needVit: UInt8
    public var int: UInt8
    public var needInt: UInt8
    public var dex: UInt8
    public var needDex: UInt8
    public var luk: UInt8
    public var needLuk: UInt8
    public var atk: Int16
    public var atk2: Int16
    public var matkMax: Int16
    public var matkMin: Int16
    public var def: Int16
    public var def2: Int16
    public var mdef: Int16
    public var mdef2: Int16
    public var hit: Int16
    public var flee: Int16
    public var flee2: Int16
    public var crit: Int16
    public var aspd: Int16
    public var aspd2: Int16

    public init(from decoder: BinaryDecoder) throws {
        try decoder.decodePacketType(Self.self)

        statusPoint = try decoder.decode(UInt16.self)
        str = try decoder.decode(UInt8.self)
        needStr = try decoder.decode(UInt8.self)
        agi = try decoder.decode(UInt8.self)
        needAgi = try decoder.decode(UInt8.self)
        vit = try decoder.decode(UInt8.self)
        needVit = try decoder.decode(UInt8.self)
        int = try decoder.decode(UInt8.self)
        needInt = try decoder.decode(UInt8.self)
        dex = try decoder.decode(UInt8.self)
        needDex = try decoder.decode(UInt8.self)
        luk = try decoder.decode(UInt8.self)
        needLuk = try decoder.decode(UInt8.self)
        atk = try decoder.decode(Int16.self)
        atk2 = try decoder.decode(Int16.self)
        matkMax = try decoder.decode(Int16.self)
        matkMin = try decoder.decode(Int16.self)
        def = try decoder.decode(Int16.self)
        def2 = try decoder.decode(Int16.self)
        mdef = try decoder.decode(Int16.self)
        mdef2 = try decoder.decode(Int16.self)
        hit = try decoder.decode(Int16.self)
        flee = try decoder.decode(Int16.self)
        flee2 = try decoder.decode(Int16.self)
        crit = try decoder.decode(Int16.self)
        aspd = try decoder.decode(Int16.self)
        aspd2 = try decoder.decode(Int16.self)
    }
}
