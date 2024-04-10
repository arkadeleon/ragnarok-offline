//
//  CharInfo.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/3/27.
//

public struct CharInfo: BinaryDecodable, BinaryEncodable {
    public let packetVersion: PacketVersion

    public var gid: UInt32 = 0
    public var baseExp: UInt64 = 0
    public var money: UInt32 = 0
    public var jobExp: UInt64 = 0
    public var jobLevel: UInt32 = 0
    public var bodyState: UInt32 = 0
    public var healthState: UInt32 = 0
    public var effectState: UInt32 = 0
    public var virtue: UInt32 = 0
    public var honor: UInt32 = 0
    public var jobPoint: UInt16 = 0
    public var hp: UInt64 = 0
    public var maxHp: UInt64 = 0
    public var sp: UInt64 = 0
    public var maxSp: UInt64 = 0
    public var speed: UInt16 = 0
    public var job: UInt16 = 0
    public var head: UInt16 = 0
    public var body: UInt16 = 0
    public var weapon: UInt16 = 0
    public var level: UInt16 = 0
    public var spPoint: UInt16 = 0
    public var accessory: UInt16 = 0
    public var shield: UInt16 = 0
    public var accessory2: UInt16 = 0
    public var accessory3: UInt16 = 0
    public var headPalette: UInt16 = 0
    public var bodyPalette: UInt16 = 0
    public var name = ""
    public var str: UInt8 = 0
    public var agi: UInt8 = 0
    public var vit: UInt8 = 0
    public var int: UInt8 = 0
    public var dex: UInt8 = 0
    public var luk: UInt8 = 0
    public var charNum: UInt8 = 0
    public var hairColor: UInt8 = 0
    public var isChangedCharName: UInt16 = 0
    public var mapName = ""
    public var deleteReservedDate: UInt32 = 0
    public var robePalette: UInt32 = 0
    public var charSlotChangeCount: UInt32 = 0
    public var charNameChangeCount: UInt32 = 0
    public var sex: UInt8 = 0

    public static func size(for packetVersion: PacketVersion) -> UInt16 {
        let encoder = BinaryEncoder()
        try? encoder.encode(CharInfo(packetVersion: packetVersion))
        let size = UInt16(encoder.data.count)
        return size
    }

    public init(packetVersion: PacketVersion) {
        self.packetVersion = packetVersion
    }

    public init(from decoder: BinaryDecoder) throws {
        packetVersion = decoder.userInfo[.packetVersionKey] as! PacketVersion

        gid = try decoder.decode(UInt32.self)

        if packetVersion.number >= 20170830 {
            baseExp = try decoder.decode(UInt64.self)
        } else {
            baseExp = try UInt64(decoder.decode(UInt32.self))
        }

        money = try decoder.decode(UInt32.self)

        if packetVersion.number >= 20170830 {
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

        if packetVersion.reNumber >= 20211103 || packetVersion.mainNumber >= 20220330 {
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

        if packetVersion.number >= 20141022 {
            body = try decoder.decode(UInt16.self)
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
        name = try decoder.decode(String.self, length: 24)
        str = try decoder.decode(UInt8.self)
        agi = try decoder.decode(UInt8.self)
        vit = try decoder.decode(UInt8.self)
        int = try decoder.decode(UInt8.self)
        dex = try decoder.decode(UInt8.self)
        luk = try decoder.decode(UInt8.self)
        charNum = try decoder.decode(UInt8.self)
        hairColor = try decoder.decode(UInt8.self)
        isChangedCharName = try decoder.decode(UInt16.self)

        if (packetVersion.number >= 20100720 && packetVersion.number <= 20100727) || 
            packetVersion.number >= 20100803 {
            mapName = try decoder.decode(String.self, length: 16)
        }

        if packetVersion.number >= 20100803 {
            deleteReservedDate = try decoder.decode(UInt32.self)
        }

        if packetVersion.number >= 20110111 {
            robePalette = try decoder.decode(UInt32.self)
        }

        if packetVersion.number >= 20110928 {
            charSlotChangeCount = try decoder.decode(UInt32.self)
        }

        if packetVersion.number >= 20111025 {
            charNameChangeCount = try decoder.decode(UInt32.self)
        }

        if packetVersion.number >= 20141016 {
            sex = try decoder.decode(UInt8.self)
        }
    }

    public func encode(to encoder: BinaryEncoder) throws {
        try encoder.encode(gid)

        if packetVersion.number >= 20170830 {
            try encoder.encode(baseExp)
        } else {
            try encoder.encode(UInt32(baseExp))
        }

        try encoder.encode(money)

        if packetVersion.number >= 20170830 {
            try encoder.encode(jobExp)
        } else {
            try encoder.encode(UInt32(jobExp))
        }

        try encoder.encode(jobLevel)
        try encoder.encode(bodyState)
        try encoder.encode(healthState)
        try encoder.encode(effectState)
        try encoder.encode(virtue)
        try encoder.encode(honor)
        try encoder.encode(jobPoint)

        if packetVersion.reNumber >= 20211103 || packetVersion.mainNumber >= 20220330 {
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
        try encoder.encode(head)

        if packetVersion.number >= 20141022 {
            try encoder.encode(body)
        }

        try encoder.encode(weapon)
        try encoder.encode(level)
        try encoder.encode(spPoint)
        try encoder.encode(accessory)
        try encoder.encode(shield)
        try encoder.encode(accessory2)
        try encoder.encode(accessory3)
        try encoder.encode(headPalette)
        try encoder.encode(bodyPalette)
        try encoder.encode(name, length: 24)
        try encoder.encode(str)
        try encoder.encode(agi)
        try encoder.encode(vit)
        try encoder.encode(int)
        try encoder.encode(dex)
        try encoder.encode(luk)
        try encoder.encode(charNum)
        try encoder.encode(hairColor)
        try encoder.encode(isChangedCharName)

        if (packetVersion.number >= 20100720 && packetVersion.number <= 20100727) || 
            packetVersion.number >= 20100803 {
            try encoder.encode(mapName, length: 16)
        }

        if packetVersion.number >= 20100803 {
            try encoder.encode(deleteReservedDate)
        }

        if packetVersion.number >= 20110111 {
            try encoder.encode(robePalette)
        }

        if packetVersion.number >= 20110928 {
            try encoder.encode(charSlotChangeCount)
        }

        if packetVersion.number >= 20111025 {
            try encoder.encode(charNameChangeCount)
        }

        if packetVersion.number >= 20141016 {
            try encoder.encode(sex)
        }
    }
}
