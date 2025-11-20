//
//  CharacterInfo.swift
//  RagnarokNetwork
//
//  Created by Leon Li on 2025/11/19.
//

import RagnarokPackets

public struct CharacterInfo: Sendable {
    public var charID: UInt32
    public var exp: Int
    public var money: Int
    public var jobExp: Int
    public var jobLevel: Int
    public var bodyState: Int
    public var healthState: Int
    public var effectState: Int
    public var virtue: Int
    public var honor: Int
    public var jobPoint: Int
    public var hp: Int
    public var maxHp: Int
    public var sp: Int
    public var maxSp: Int
    public var speed: Int
    public var job: Int
    public var head: Int
    public var body: Int
    public var weapon: Int
    public var level: Int
    public var spPoint: Int
    public var accessory: Int
    public var shield: Int
    public var accessory2: Int
    public var accessory3: Int
    public var headPalette: Int
    public var bodyPalette: Int
    public var name: String
    public var str: Int
    public var agi: Int
    public var vit: Int
    public var int: Int
    public var dex: Int
    public var luk: Int
    public var charNum: Int
    public var hairColor: Int
    public var bIsChangedCharName: Int
    public var mapName: String
    public var delRevDate: Int
    public var robePalette: Int
    public var charSlotChangeCount: Int
    public var charNameChangeCount: Int
    public var sex: Int

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

    public init(from character: CHARACTER_INFO) {
        charID = character.GID
        exp = Int(character.exp)
        money = Int(character.money)
        jobExp = Int(character.jobexp)
        jobLevel = Int(character.joblevel)
        bodyState = Int(character.bodystate)
        healthState = Int(character.healthstate)
        effectState = Int(character.effectstate)
        virtue = Int(character.virtue)
        honor = Int(character.honor)
        jobPoint = Int(character.jobpoint)
        hp = Int(character.hp)
        maxHp = Int(character.maxhp)
        sp = Int(character.sp)
        maxSp = Int(character.maxsp)
        speed = Int(character.speed)
        job = Int(character.job)
        head = Int(character.head)
        body = Int(character.body)
        weapon = Int(character.weapon)
        level = Int(character.level)
        spPoint = Int(character.sppoint)
        accessory = Int(character.accessory)
        shield = Int(character.shield)
        accessory2 = Int(character.accessory2)
        accessory3 = Int(character.accessory3)
        headPalette = Int(character.headpalette)
        bodyPalette = Int(character.bodypalette)
        name = character.name
        str = Int(character.Str)
        agi = Int(character.Agi)
        vit = Int(character.Vit)
        int = Int(character.Int)
        dex = Int(character.Dex)
        luk = Int(character.Luk)
        charNum = Int(character.CharNum)
        hairColor = Int(character.hairColor)
        bIsChangedCharName = Int(character.bIsChangedCharName)
        mapName = character.mapName
        delRevDate = Int(character.DelRevDate)
        robePalette = Int(character.robePalette)
        charSlotChangeCount = Int(character.chr_slot_changeCnt)
        charNameChangeCount = Int(character.chr_name_changeCnt)
        sex = Int(character.sex)
    }
}
