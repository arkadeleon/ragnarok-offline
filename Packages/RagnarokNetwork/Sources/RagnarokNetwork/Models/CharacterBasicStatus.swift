//
//  CharacterBasicStatus.swift
//  RagnarokNetwork
//
//  Created by Leon Li on 2024/12/13.
//

import RagnarokPackets

public struct CharacterBasicStatus: Sendable {
    public var str = 0
    public var str3 = 0
    public var agi = 0
    public var agi3 = 0
    public var vit = 0
    public var vit3 = 0
    public var int = 0
    public var int3 = 0
    public var dex = 0
    public var dex3 = 0
    public var luk = 0
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

    init(from packet: PACKET_ZC_STATUS) {
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
}
