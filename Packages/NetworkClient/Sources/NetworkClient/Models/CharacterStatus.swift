//
//  CharacterStatus.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/12/13.
//

import Constants
import NetworkPackets

public struct CharacterStatus: Sendable {
    public private(set) var hp = 0
    public private(set) var maxHp = 0
    public private(set) var sp = 0
    public private(set) var maxSp = 0

    public private(set) var baseLevel = 0
    public private(set) var baseExp = 0
    public private(set) var baseExpNext = 0

    public private(set) var jobLevel = 0
    public private(set) var jobExp = 0
    public private(set) var jobExpNext = 0

    public private(set) var weight = 0
    public private(set) var maxWeight = 0

    public private(set) var zeny = 0

    public private(set) var str = 0
    public private(set) var str2 = 0
    public private(set) var str3 = 0
    public private(set) var agi = 0
    public private(set) var agi2 = 0
    public private(set) var agi3 = 0
    public private(set) var vit = 0
    public private(set) var vit2 = 0
    public private(set) var vit3 = 0
    public private(set) var int = 0
    public private(set) var int2 = 0
    public private(set) var int3 = 0
    public private(set) var dex = 0
    public private(set) var dex2 = 0
    public private(set) var dex3 = 0
    public private(set) var luk = 0
    public private(set) var luk2 = 0
    public private(set) var luk3 = 0

    public private(set) var atk = 0
    public private(set) var atk2 = 0
    public private(set) var def = 0
    public private(set) var def2 = 0
    public private(set) var matk = 0
    public private(set) var matk2 = 0
    public private(set) var mdef = 0
    public private(set) var mdef2 = 0
    public private(set) var hit = 0
    public private(set) var flee = 0
    public private(set) var flee2 = 0
    public private(set) var critical = 0
    public private(set) var aspd = 0
    public private(set) var statusPoint = 0

    public init() {
    }

    mutating func update(with packet: PACKET_ZC_STATUS) {
        str = Int(packet.str)
        str3 = Int(packet.standardStr)
        agi = Int(packet.agi)
        agi3 = Int(packet.standardAgi)
        vit = Int(packet.vit)
        vit3 = Int(packet.standardVit)
        int = Int(packet.int_)
        int3 = Int(packet.standardInt)
        dex = Int(packet.dex)
        dex3 = Int(packet.standardDex)
        luk = Int(packet.luk)
        luk3 = Int(packet.standardLuk)

        atk = Int(packet.attPower)
        atk2 = Int(packet.refiningPower)
        def = Int(packet.itemdefPower)
        def2 = Int(packet.plusdefPower)
        matk = Int(packet.min_mattPower)
        matk2 = Int(packet.max_mattPower)
        mdef = Int(packet.mdefPower)
        mdef2 = Int(packet.plusmdefPower)
        hit = Int(packet.hitSuccessValue)
        flee = Int(packet.avoidSuccessValue)
        flee2 = Int(packet.plusAvoidSuccessValue)
        critical = Int(packet.criticalSuccessValue)
        aspd = Int(packet.ASPD + packet.plusASPD) / 4
        statusPoint = Int(packet.point)
    }

    mutating func update(property: StatusProperty, value: Int) {
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

    mutating func update(property: StatusProperty, value: Int, value2: Int) {
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
