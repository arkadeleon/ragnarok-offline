//
//  CharInfo.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/27.
//

public struct CharInfo: BinaryDecodable {
    public var charID: UInt32
    public var baseExp: UInt64
    public var zeny: UInt32
    public var jobExp: UInt64
    public var jobLevel: UInt32
    public var bodyState: UInt32
    public var healthState: UInt32
    public var effectState: UInt32
    public var karma: UInt32
    public var manner: UInt32
    public var statusPoint: UInt16
    public var hp: UInt64
    public var maxHp: UInt64
    public var sp: UInt64
    public var maxSp: UInt64
    public var speed: UInt16
    public var job: UInt16
    public var hair: UInt16
    public var body: UInt16
    public var weapon: UInt16
    public var baseLevel: UInt16
    public var skillPoint: UInt16
    public var headBottom: UInt16
    public var shield: UInt16
    public var headTop: UInt16
    public var headMiddle: UInt16
    public var hairColor: UInt16
    public var clothesColor: UInt16
    public var name: String
    public var str: UInt8
    public var agi: UInt8
    public var vit: UInt8
    public var int: UInt8
    public var dex: UInt8
    public var luk: UInt8
    public var slot: UInt8
    public var hairColor2: UInt8
    public var isRenamed: UInt16
    public var mapName: String
    public var deletionDate: UInt32
    public var robe: UInt32
    public var charSlotChangeCount: UInt32
    public var charNameChangeCount: UInt32
    public var sex: UInt8

    public init(from decoder: BinaryDecoder) throws {
        charID = try decoder.decode(UInt32.self)

        if PACKET_VERSION >= 20170830 {
            baseExp = try decoder.decode(UInt64.self)
        } else {
            baseExp = try UInt64(decoder.decode(UInt32.self))
        }

        zeny = try decoder.decode(UInt32.self)

        if PACKET_VERSION >= 20170830 {
            jobExp = try decoder.decode(UInt64.self)
        } else {
            jobExp = try UInt64(decoder.decode(UInt32.self))
        }

        jobLevel = try decoder.decode(UInt32.self)
        bodyState = try decoder.decode(UInt32.self)
        healthState = try decoder.decode(UInt32.self)
        effectState = try decoder.decode(UInt32.self)
        karma = try decoder.decode(UInt32.self)
        manner = try decoder.decode(UInt32.self)
        statusPoint = try decoder.decode(UInt16.self)

        if PACKET_VERSION_RE_NUMBER >= 20211103 || PACKET_VERSION_MAIN_NUMBER >= 20220330 {
            hp = try decoder.decode(UInt64.self)
            maxHp = try decoder.decode(UInt64.self)
            sp = try decoder.decode(UInt64.self)
            maxSp = try decoder.decode(UInt64.self)
        } else {
            hp = try UInt64(decoder.decode(UInt32.self))
            maxHp = try UInt64(decoder.decode(UInt32.self))
            sp = try UInt64(decoder.decode(UInt16.self))
            maxSp = try UInt64(decoder.decode(UInt16.self))
        }

        speed = try decoder.decode(UInt16.self)
        job = try decoder.decode(UInt16.self)
        hair = try decoder.decode(UInt16.self)

        if PACKET_VERSION >= 20141022 {
            body = try decoder.decode(UInt16.self)
        } else {
            body = 0
        }

        weapon = try decoder.decode(UInt16.self)
        baseLevel = try decoder.decode(UInt16.self)
        skillPoint = try decoder.decode(UInt16.self)
        headBottom = try decoder.decode(UInt16.self)
        shield = try decoder.decode(UInt16.self)
        headTop = try decoder.decode(UInt16.self)
        headMiddle = try decoder.decode(UInt16.self)
        hairColor = try decoder.decode(UInt16.self)
        clothesColor = try decoder.decode(UInt16.self)
        name = try decoder.decode(String.self, length: 24)
        str = try decoder.decode(UInt8.self)
        agi = try decoder.decode(UInt8.self)
        vit = try decoder.decode(UInt8.self)
        int = try decoder.decode(UInt8.self)
        dex = try decoder.decode(UInt8.self)
        luk = try decoder.decode(UInt8.self)
        slot = try decoder.decode(UInt8.self)
        hairColor2 = try decoder.decode(UInt8.self)
        isRenamed = try decoder.decode(UInt16.self)

        if (PACKET_VERSION >= 20100720 && PACKET_VERSION <= 20100727) || 
            PACKET_VERSION >= 20100803 {
            mapName = try decoder.decode(String.self, length: 16)
        } else {
            mapName = ""
        }

        if PACKET_VERSION >= 20100803 {
            deletionDate = try decoder.decode(UInt32.self)
        } else {
            deletionDate = 0
        }

        if PACKET_VERSION >= 20110111 {
            robe = try decoder.decode(UInt32.self)
        } else {
            robe = 0
        }

        if PACKET_VERSION >= 20110928 {
            charSlotChangeCount = try decoder.decode(UInt32.self)
        } else {
            charSlotChangeCount = 0
        }

        if PACKET_VERSION >= 20111025 {
            charNameChangeCount = try decoder.decode(UInt32.self)
        } else {
            charNameChangeCount = 0
        }

        if PACKET_VERSION >= 20141016 {
            sex = try decoder.decode(UInt8.self)
        } else {
            sex = 0
        }
    }
}
