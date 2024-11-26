//
//  NormalItemInfo.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/28.
//

import ROCore

public struct _NormalItemInfo: BinaryDecodable, Sendable {
    public var index: Int16
    public var itemID: UInt32
    public var type: UInt8
    public var isIdentified: UInt8
    public var count: Int16
    public var wearState: UInt32
    public var slot: [UInt32]
    public var hireExpireDate: Int32
    public var flag: UInt8

    public init(from decoder: BinaryDecoder) throws {
        index = try decoder.decode(Int16.self)

        if PACKET_VERSION_MAIN_NUMBER >= 20181121 || PACKET_VERSION_RE_NUMBER >= 20180704 || PACKET_VERSION_ZERO_NUMBER >= 20181114 {
            itemID = try decoder.decode(UInt32.self)
        } else {
            itemID = UInt32(try decoder.decode(UInt16.self))
        }

        type = try decoder.decode(UInt8.self)

        if PACKET_VERSION < 20120925 {
            isIdentified = try decoder.decode(UInt8.self)
        } else {
            isIdentified = 0
        }

        count = try decoder.decode(Int16.self)

        if PACKET_VERSION >= 20120925 {
            wearState = try decoder.decode(UInt32.self)
        } else {
            wearState = UInt32(try decoder.decode(UInt16.self))
        }

        if PACKET_VERSION >= 5 {
            if PACKET_VERSION_MAIN_NUMBER >= 20181121 || PACKET_VERSION_RE_NUMBER >= 20180704 || PACKET_VERSION_ZERO_NUMBER >= 20181114 {
                slot = try [
                    decoder.decode(UInt32.self),
                    decoder.decode(UInt32.self),
                    decoder.decode(UInt32.self),
                    decoder.decode(UInt32.self),
                ]
            } else {
                slot = try [
                    UInt32(decoder.decode(UInt16.self)),
                    UInt32(decoder.decode(UInt16.self)),
                    UInt32(decoder.decode(UInt16.self)),
                    UInt32(decoder.decode(UInt16.self)),
                ]
            }
        } else {
            slot = [0, 0, 0, 0]
        }

        if PACKET_VERSION >= 20080102 {
            hireExpireDate = try decoder.decode(Int32.self)
        } else {
            hireExpireDate = 0
        }

        if PACKET_VERSION >= 20120925 {
            flag = try decoder.decode(UInt8.self)
        } else {
            flag = 0
        }
    }
}
