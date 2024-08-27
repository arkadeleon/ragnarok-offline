//
//  CharInfo.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/27.
//

public struct CharInfo: BinaryDecodable, BinaryEncodable {
    public static var size: Int16 {
        let encoder = BinaryEncoder()
        try? encoder.encode(CharInfo())
        let size = Int16(encoder.data.count)
        return size
    }

    public var charID: UInt32 = 0
    public var baseExp: UInt64 = 0
    public var zeny: UInt32 = 0
    public var jobExp: UInt64 = 0
    public var jobLevel: UInt32 = 0
    public var bodyState: UInt32 = 0
    public var healthState: UInt32 = 0
    public var effectState: UInt32 = 0
    public var karma: UInt32 = 0
    public var manner: UInt32 = 0
    public var statusPoint: UInt16 = 0
    public var hp: UInt64 = 0
    public var maxHp: UInt64 = 0
    public var sp: UInt64 = 0
    public var maxSp: UInt64 = 0
    public var speed: UInt16 = 0
    public var job: UInt16 = 0
    public var hair: UInt16 = 0
    public var body: UInt16 = 0
    public var weapon: UInt16 = 0
    public var baseLevel: UInt16 = 0
    public var skillPoint: UInt16 = 0
    public var headBottom: UInt16 = 0
    public var shield: UInt16 = 0
    public var headTop: UInt16 = 0
    public var headMiddle: UInt16 = 0
    public var hairColor: UInt16 = 0
    public var clothesColor: UInt16 = 0
    public var name = ""
    public var str: UInt8 = 0
    public var agi: UInt8 = 0
    public var vit: UInt8 = 0
    public var int: UInt8 = 0
    public var dex: UInt8 = 0
    public var luk: UInt8 = 0
    public var slot: UInt8 = 0
    public var hairColor2: UInt8 = 0
    public var isRenamed: UInt16 = 0
    public var mapName = ""
    public var deletionDate: UInt32 = 0
    public var robe: UInt32 = 0
    public var charSlotChangeCount: UInt32 = 0
    public var charNameChangeCount: UInt32 = 0
    public var sex: UInt8 = 0

    public init() {
    }

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
        }

        if PACKET_VERSION >= 20100803 {
            deletionDate = try decoder.decode(UInt32.self)
        }

        if PACKET_VERSION >= 20110111 {
            robe = try decoder.decode(UInt32.self)
        }

        if PACKET_VERSION >= 20110928 {
            charSlotChangeCount = try decoder.decode(UInt32.self)
        }

        if PACKET_VERSION >= 20111025 {
            charNameChangeCount = try decoder.decode(UInt32.self)
        }

        if PACKET_VERSION >= 20141016 {
            sex = try decoder.decode(UInt8.self)
        }
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(charID)

        if PACKET_VERSION >= 20170830 {
            try encoder.encode(baseExp)
        } else {
            try encoder.encode(UInt32(baseExp))
        }

        try encoder.encode(zeny)

        if PACKET_VERSION >= 20170830 {
            try encoder.encode(jobExp)
        } else {
            try encoder.encode(UInt32(jobExp))
        }

        try encoder.encode(jobLevel)
        try encoder.encode(bodyState)
        try encoder.encode(healthState)
        try encoder.encode(effectState)
        try encoder.encode(karma)
        try encoder.encode(manner)
        try encoder.encode(statusPoint)

        if PACKET_VERSION_RE_NUMBER >= 20211103 || PACKET_VERSION_MAIN_NUMBER >= 20220330 {
            try encoder.encode(hp)
            try encoder.encode(maxHp)
            try encoder.encode(sp)
            try encoder.encode(maxSp)
        } else {
            try encoder.encode(UInt32(hp))
            try encoder.encode(UInt32(maxHp))
            try encoder.encode(UInt16(sp))
            try encoder.encode(UInt16(maxSp))
        }

        try encoder.encode(speed)
        try encoder.encode(job)
        try encoder.encode(hair)

        if PACKET_VERSION >= 20141022 {
            try encoder.encode(body)
        }

        try encoder.encode(weapon)
        try encoder.encode(baseLevel)
        try encoder.encode(skillPoint)
        try encoder.encode(headBottom)
        try encoder.encode(shield)
        try encoder.encode(headTop)
        try encoder.encode(headMiddle)
        try encoder.encode(hairColor)
        try encoder.encode(clothesColor)
        try encoder.encode(name, length: 24)
        try encoder.encode(str)
        try encoder.encode(agi)
        try encoder.encode(vit)
        try encoder.encode(int)
        try encoder.encode(dex)
        try encoder.encode(luk)
        try encoder.encode(slot)
        try encoder.encode(hairColor2)
        try encoder.encode(isRenamed)

        if (PACKET_VERSION >= 20100720 && PACKET_VERSION <= 20100727) || 
            PACKET_VERSION >= 20100803 {
            try encoder.encode(mapName, length: 16)
        }

        if PACKET_VERSION >= 20100803 {
            try encoder.encode(deletionDate)
        }

        if PACKET_VERSION >= 20110111 {
            try encoder.encode(robe)
        }

        if PACKET_VERSION >= 20110928 {
            try encoder.encode(charSlotChangeCount)
        }

        if PACKET_VERSION >= 20111025 {
            try encoder.encode(charNameChangeCount)
        }

        if PACKET_VERSION >= 20141016 {
            try encoder.encode(sex)
        }
    }
}
