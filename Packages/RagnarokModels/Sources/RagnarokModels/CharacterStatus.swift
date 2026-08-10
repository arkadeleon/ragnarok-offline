//
//  CharacterStatus.swift
//  RagnarokModels
//
//  Created by Leon Li on 2024/12/13.
//

import RagnarokConstants
import RagnarokPackets

public struct CharacterStatus {
    public var hp = 0
    public var maxHp = 0
    public var sp = 0
    public var maxSp = 0

    public var baseLevel = 0
    public var baseExp = 0
    public var baseExpNext = 0

    public var jobLevel = 0
    public var jobExp = 0
    public var jobExpNext = 0

    public var weight = 0
    public var maxWeight = 0

    public var zeny = 0

    public var str = 0
    public var str2 = 0
    public var str3 = 0
    public var agi = 0
    public var agi2 = 0
    public var agi3 = 0
    public var vit = 0
    public var vit2 = 0
    public var vit3 = 0
    public var int = 0
    public var int2 = 0
    public var int3 = 0
    public var dex = 0
    public var dex2 = 0
    public var dex3 = 0
    public var luk = 0
    public var luk2 = 0
    public var luk3 = 0

    public var atk = 0
    public var atk2 = 0
    public var def = 0
    public var def2 = 0
    public var matk = 0
    public var matk2 = 0
    public var mdef = 0
    public var mdef2 = 0
    public var hit = 0
    public var flee = 0
    public var flee2 = 0
    public var critical = 0
    public var aspd = 0
    public var statusPoint = 0

    public var skillPoint = 0

    public var attackRange = 0

    public init() {
    }

    public init(from character: CharacterInfo) {
        hp = character.hp
        maxHp = character.maxHp
        sp = character.sp
        maxSp = character.maxSp

        baseLevel = character.level
        baseExp = character.exp

        jobLevel = character.jobLevel
        jobExp = character.jobExp

        zeny = character.money

        str = character.str
        agi = character.agi
        vit = character.vit
        int = character.int
        dex = character.dex
        luk = character.luk
    }

    public mutating func update(from basicStatus: CharacterBasicStatus) {
        str = basicStatus.str
        str3 = basicStatus.str3
        agi = basicStatus.agi
        agi3 = basicStatus.agi3
        vit = basicStatus.vit
        vit3 = basicStatus.vit3
        int = basicStatus.int
        int3 = basicStatus.int3
        dex = basicStatus.dex
        dex3 = basicStatus.dex3
        luk = basicStatus.luk
        luk3 = basicStatus.luk3

        atk = basicStatus.atk
        atk2 = basicStatus.atk2
        def = basicStatus.def
        def2 = basicStatus.def2
        matk = basicStatus.matk
        matk2 = basicStatus.matk2
        mdef = basicStatus.mdef
        mdef2 = basicStatus.mdef2
        hit = basicStatus.hit
        flee = basicStatus.flee
        flee2 = basicStatus.flee2
        critical = basicStatus.critical
        aspd = basicStatus.aspd
        statusPoint = basicStatus.statusPoint
    }

    public mutating func update(property: StatusProperty, value: Int) {
        switch property {
        case .hp:
            hp = value
        case .maxhp:
            maxHp = value
        case .sp:
            sp = value
        case .maxsp:
            maxSp = value
        case .baselevel:
            baseLevel = value
        case .baseexp:
            baseExp = value
        case .nextbaseexp:
            baseExpNext = value
        case .joblevel:
            jobLevel = value
        case .jobexp:
            jobExp = value
        case .nextjobexp:
            jobExpNext = value
        case .weight:
            weight = value
        case .maxweight:
            maxWeight = value
        case .zeny:
            zeny = value
        case .ustr:
            str3 = value
        case .uagi:
            agi3 = value
        case .uvit:
            vit3 = value
        case .uint:
            int3 = value
        case .udex:
            dex3 = value
        case .uluk:
            luk3 = value
        case .atk1:
            atk = value
        case .atk2:
            atk2 = value
        case .def1:
            def = value
        case .def2:
            def2 = value
        case .matk1:
            matk = value
        case .matk2:
            matk2 = value
        case .mdef1:
            mdef = value
        case .mdef2:
            mdef2 = value
        case .hit:
            hit = value
        case .flee1:
            flee = value
        case .flee2:
            flee2 = value
        case .critical:
            critical = value
        case .aspd:
            aspd = value / 4
        case .statuspoint:
            statusPoint = value
        case .skillpoint:
            skillPoint = value
        default:
            break
        }
    }

    public mutating func update(property: StatusProperty, value: Int, value2: Int) {
        switch property {
        case .str:
            str = value
            str2 = value2
        case .agi:
            agi = value
            agi2 = value2
        case .vit:
            vit = value
            vit2 = value2
        case .int:
            int = value
            int2 = value2
        case .dex:
            dex = value
            dex2 = value2
        case .luk:
            luk = value
            luk2 = value2
        default:
            break
        }
    }

    public mutating func update(from packet: PACKET_ZC_ATTACK_RANGE) {
        attackRange = Int(packet.currentAttRange)
    }
}
