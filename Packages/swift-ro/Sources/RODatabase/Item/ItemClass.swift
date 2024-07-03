//
//  ItemClass.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/10.
//

import rAthenaCommon

public enum ItemClass: CaseIterable, RawRepresentable, CodingKey, Decodable {
    case all
    case normal
    case upper
    case baby
    case third
    case thirdUpper
    case thirdBaby
    case fourth
    case allUpper
    case allBaby
    case allThird

    public var rawValue: Int {
        switch self {
        case .all:
            switch CurrentServerMode {
            case .prerenewal:
                RA_ITEMJ_NORMAL | RA_ITEMJ_UPPER | RA_ITEMJ_BABY
            case .renewal:
                RA_ITEMJ_NORMAL | RA_ITEMJ_UPPER | RA_ITEMJ_BABY | RA_ITEMJ_THIRD | RA_ITEMJ_THIRD_UPPER | RA_ITEMJ_THIRD_BABY | RA_ITEMJ_FOURTH
            }
        case .normal: RA_ITEMJ_NORMAL
        case .upper: RA_ITEMJ_UPPER
        case .baby: RA_ITEMJ_BABY
        case .third: RA_ITEMJ_THIRD
        case .thirdUpper: RA_ITEMJ_THIRD_UPPER
        case .thirdBaby: RA_ITEMJ_THIRD_BABY
        case .fourth: RA_ITEMJ_FOURTH
        case .allUpper: RA_ITEMJ_ALL_UPPER
        case .allBaby: RA_ITEMJ_ALL_BABY
        case .allThird: RA_ITEMJ_ALL_THIRD
        }
    }

    public var stringValue: String {
        switch self {
        case .all: "All"
        case .normal: "Normal"
        case .upper: "Upper"
        case .baby: "Baby"
        case .third: "Third"
        case .thirdUpper: "Third_Upper"
        case .thirdBaby: "Third_Baby"
        case .fourth: "Fourth"
        case .allUpper: "All_Upper"
        case .allBaby: "All_Baby"
        case .allThird: "All_Third"
        }
    }
}
