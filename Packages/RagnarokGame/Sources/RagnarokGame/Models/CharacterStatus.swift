//
//  CharacterStatus.swift
//  RagnarokGame
//
//  Created by Leon Li on 2024/12/13.
//

import Observation
import RagnarokConstants
import RagnarokModels

@Observable
final class CharacterStatus {
    var hp = 0
    var maxHp = 0
    var sp = 0
    var maxSp = 0

    var baseLevel = 0
    var baseExp = 0
    var baseExpNext = 0

    var jobLevel = 0
    var jobExp = 0
    var jobExpNext = 0

    var weight = 0
    var maxWeight = 0

    var zeny = 0

    var str = 0
    var str2 = 0
    var str3 = 0
    var agi = 0
    var agi2 = 0
    var agi3 = 0
    var vit = 0
    var vit2 = 0
    var vit3 = 0
    var int = 0
    var int2 = 0
    var int3 = 0
    var dex = 0
    var dex2 = 0
    var dex3 = 0
    var luk = 0
    var luk2 = 0
    var luk3 = 0

    var atk = 0
    var atk2 = 0
    var def = 0
    var def2 = 0
    var matk = 0
    var matk2 = 0
    var mdef = 0
    var mdef2 = 0
    var hit = 0
    var flee = 0
    var flee2 = 0
    var critical = 0
    var aspd = 0
    var statusPoint = 0

    init() {
    }

    init(from character: CharacterInfo) {
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

    func update(from basicStatus: CharacterBasicStatus) {
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

    func update(property: StatusProperty, value: Int) {
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
        default:
            break
        }
    }

    func update(property: StatusProperty, value: Int, value2: Int) {
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
}
