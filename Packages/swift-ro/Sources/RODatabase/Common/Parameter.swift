//
//  Parameter.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/10.
//

import rAthenaCommon

public enum Parameter: Option {
    case str
    case agi
    case vit
    case int
    case dex
    case luk
    case pow
    case sta
    case wis
    case spl
    case con
    case crt

    public var intValue: Int {
        switch self {
        case .str: RA_PARAM_STR
        case .agi: RA_PARAM_AGI
        case .vit: RA_PARAM_VIT
        case .int: RA_PARAM_INT
        case .dex: RA_PARAM_DEX
        case .luk: RA_PARAM_LUK
        case .pow: RA_PARAM_POW
        case .sta: RA_PARAM_STA
        case .wis: RA_PARAM_WIS
        case .spl: RA_PARAM_SPL
        case .con: RA_PARAM_CON
        case .crt: RA_PARAM_CRT
        }
    }

    public var stringValue: String {
        switch self {
        case .str: "Str"
        case .agi: "Agi"
        case .vit: "Vit"
        case .int: "Int"
        case .dex: "Dex"
        case .luk: "Luk"
        case .pow: "Pow"
        case .sta: "Sta"
        case .wis: "Wis"
        case .spl: "Spl"
        case .con: "Con"
        case .crt: "Crt"
        }
    }
}
