//
//  CharInfo.swift
//  RagnarokPackets
//
//  Created by Leon Li on 2024/3/27.
//

import BinaryIO

public struct CharInfo: BinaryDecodable, Sendable {
    public var charID: UInt32
    public var exp: UInt64
    public var money: UInt32
    public var jobExp: UInt64
    public var jobLevel: UInt32
    public var bodyState: UInt32
    public var healthState: UInt32
    public var effectState: UInt32
    public var virtue: UInt32
    public var honor: UInt32
    public var jobPoint: UInt16
    public var hp: UInt64
    public var maxHp: UInt64
    public var sp: UInt64
    public var maxSp: UInt64
    public var speed: UInt16
    public var job: UInt16
    public var head: UInt16
    public var body: UInt16
    public var weapon: UInt16
    public var level: UInt16
    public var spPoint: UInt16
    public var accessory: UInt16
    public var shield: UInt16
    public var accessory2: UInt16
    public var accessory3: UInt16
    public var headPalette: UInt16
    public var bodyPalette: UInt16
    public var name: String
    public var str: UInt8
    public var agi: UInt8
    public var vit: UInt8
    public var int: UInt8
    public var dex: UInt8
    public var luk: UInt8
    public var charNum: UInt8
    public var hairColor: UInt8
    public var bIsChangedCharName: UInt16
    public var mapName: String
    public var delRevDate: UInt32
    public var robePalette: UInt32
    public var charSlotChangeCount: UInt32
    public var charNameChangeCount: UInt32
    public var sex: UInt8

    public init() {
        charID = 0
        exp = 0
        money = 0
        jobExp = 0
        jobLevel = 0
        bodyState = 0
        healthState = 0
        effectState = 0
        virtue = 0
        honor = 0
        jobPoint = 0
        hp = 0
        maxHp = 0
        sp = 0
        maxSp = 0
        speed = 0
        job = 0
        head = 0
        body = 0
        weapon = 0
        level = 0
        spPoint = 0
        accessory = 0
        shield = 0
        accessory2 = 0
        accessory3 = 0
        headPalette = 0
        bodyPalette = 0
        name = ""
        str = 0
        agi = 0
        vit = 0
        int = 0
        dex = 0
        luk = 0
        charNum = 0
        hairColor = 0
        bIsChangedCharName = 0
        mapName = ""
        delRevDate = 0
        robePalette = 0
        charSlotChangeCount = 0
        charNameChangeCount = 0
        sex = 0
    }

    public init(from decoder: BinaryDecoder) throws {
        charID = try decoder.decode(UInt32.self)

        if PACKET_VERSION >= 20170830 {
            exp = try decoder.decode(UInt64.self)
        } else {
            exp = try UInt64(decoder.decode(UInt32.self))
        }

        money = try decoder.decode(UInt32.self)

        if PACKET_VERSION >= 20170830 {
            jobExp = try decoder.decode(UInt64.self)
        } else {
            jobExp = try UInt64(decoder.decode(UInt32.self))
        }

        jobLevel = try decoder.decode(UInt32.self)
        bodyState = try decoder.decode(UInt32.self)
        healthState = try decoder.decode(UInt32.self)
        effectState = try decoder.decode(UInt32.self)
        virtue = try decoder.decode(UInt32.self)
        honor = try decoder.decode(UInt32.self)
        jobPoint = try decoder.decode(UInt16.self)

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
        head = try decoder.decode(UInt16.self)

        if PACKET_VERSION >= 20141022 {
            body = try decoder.decode(UInt16.self)
        } else {
            body = 0
        }

        weapon = try decoder.decode(UInt16.self)
        level = try decoder.decode(UInt16.self)
        spPoint = try decoder.decode(UInt16.self)
        accessory = try decoder.decode(UInt16.self)
        shield = try decoder.decode(UInt16.self)
        accessory2 = try decoder.decode(UInt16.self)
        accessory3 = try decoder.decode(UInt16.self)
        headPalette = try decoder.decode(UInt16.self)
        bodyPalette = try decoder.decode(UInt16.self)
        name = try decoder.decode(String.self, lengthOfBytes: 24)
        str = try decoder.decode(UInt8.self)
        agi = try decoder.decode(UInt8.self)
        vit = try decoder.decode(UInt8.self)
        int = try decoder.decode(UInt8.self)
        dex = try decoder.decode(UInt8.self)
        luk = try decoder.decode(UInt8.self)
        charNum = try decoder.decode(UInt8.self)
        hairColor = try decoder.decode(UInt8.self)
        bIsChangedCharName = try decoder.decode(UInt16.self)

        if (PACKET_VERSION >= 20100720 && PACKET_VERSION <= 20100727) || 
            PACKET_VERSION >= 20100803 {
            mapName = try decoder.decode(String.self, lengthOfBytes: 16)
        } else {
            mapName = ""
        }

        if PACKET_VERSION >= 20100803 {
            delRevDate = try decoder.decode(UInt32.self)
        } else {
            delRevDate = 0
        }

        if PACKET_VERSION >= 20110111 {
            robePalette = try decoder.decode(UInt32.self)
        } else {
            robePalette = 0
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
