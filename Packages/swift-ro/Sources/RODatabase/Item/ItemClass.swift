//
//  ItemClass.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/10.
//

import rAthenaCommon

public enum ItemClass: String, CaseIterable, CodingKey, Decodable {

    /// Applies to all classes.
    case all = "All"

    /// Normal classes (no Baby/Transcendent/Third classes).
    case normal = "Normal"

    /// Transcedent classes (no Transcedent-Third classes).
    case upper = "Upper"

    /// Baby classes (no Third-Baby classes).
    case baby = "Baby"

    /// Third classes (no Transcedent-Third or Third-Baby classes).
    case third = "Third"

    /// Transcedent-Third classes.
    case thirdUpper = "Third_Upper"

    /// Third-Baby classes.
    case thirdBaby = "Third_Baby"

    /// Fourth classes.
    case fourth = "Fourth"

    /// All Transcedent classes
    case allUpper = "All_Upper"

    /// All baby classes
    case allBaby = "All_Baby"

    /// Applies to all Third classes.
    case allThird = "All_Third"
}

extension ItemClass: Identifiable {
    public var id: Int {
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
}

extension ItemClass: CustomStringConvertible {
    public var description: String {
        stringValue
    }
}
