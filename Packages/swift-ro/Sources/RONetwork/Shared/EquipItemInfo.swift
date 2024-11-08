//
//  EquipItemInfo.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/28.
//

import ROCore

public struct EquipItemInfo: BinaryDecodable, Sendable {
    public var index: Int16
    public var itemID: UInt32
    public var type: UInt8
    public var isIdentified: UInt8
    public var location: UInt32
    public var wearState: UInt32
    public var isDamaged: UInt8
    public var refiningLevel: UInt8
    public var slot: [UInt32]
    public var hireExpireDate: Int32
    public var bindOnEquipType: UInt16
    public var wItemSpriteNumber: UInt16
    public var optionCount: UInt8
    public var optionData: [ItemOptions]
    public var grade: UInt8
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

        if PACKET_VERSION >= 20120925 {
            location = try decoder.decode(UInt32.self)
            wearState = try decoder.decode(UInt32.self)
        } else {
            location = UInt32(try decoder.decode(UInt16.self))
            wearState = UInt32(try decoder.decode(UInt16.self))
        }

        if PACKET_VERSION < 20120925 {
            isDamaged = try decoder.decode(UInt8.self)
        } else {
            isDamaged = 0
        }

        if !(PACKET_VERSION_MAIN_NUMBER >= 20200916 || PACKET_VERSION_RE_NUMBER >= 20200723 || PACKET_VERSION_ZERO_NUMBER >= 20221024) {
            refiningLevel = try decoder.decode(UInt8.self)
        } else {
            refiningLevel = 0
        }

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

        if PACKET_VERSION >= 20071002 {
            hireExpireDate = try decoder.decode(Int32.self)
        } else {
            hireExpireDate = 0
        }

        if PACKET_VERSION >= 20080102 {
            bindOnEquipType = try decoder.decode(UInt16.self)
        } else {
            bindOnEquipType = 0
        }

        if PACKET_VERSION >= 20100629 {
            wItemSpriteNumber = try decoder.decode(UInt16.self)
        } else {
            wItemSpriteNumber = 0
        }

        if PACKET_VERSION >= 20150226 {
            optionCount = try decoder.decode(UInt8.self)
            optionData = try [
                ItemOptions(from: decoder),
                ItemOptions(from: decoder),
                ItemOptions(from: decoder),
                ItemOptions(from: decoder),
                ItemOptions(from: decoder),
            ]
        } else {
            optionCount = 0
            optionData = []
        }

        if PACKET_VERSION_MAIN_NUMBER >= 20200916 || PACKET_VERSION_RE_NUMBER >= 20200723 || PACKET_VERSION_ZERO_NUMBER >= 20221024 {
            refiningLevel = try decoder.decode(UInt8.self)
            grade = try decoder.decode(UInt8.self)
        } else {
            grade = 0
        }

        if PACKET_VERSION >= 20120925 {
            flag = try decoder.decode(UInt8.self)
        } else {
            flag = 0
        }
    }
}
