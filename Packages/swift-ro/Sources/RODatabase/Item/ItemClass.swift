//
//  ItemClass.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/10.
//

import rAthenaCommon

public enum ItemClass: Option {
    case normal
    case upper
    case baby
    case third
    case thirdUpper
    case thirdBaby
    case fourth

    public var intValue: Int {
        switch self {
        case .normal: RA_ITEMJ_NORMAL
        case .upper: RA_ITEMJ_UPPER
        case .baby: RA_ITEMJ_BABY
        case .third: RA_ITEMJ_THIRD
        case .thirdUpper: RA_ITEMJ_THIRD_UPPER
        case .thirdBaby: RA_ITEMJ_THIRD_BABY
        case .fourth: RA_ITEMJ_FOURTH
        }
    }

    public var stringValue: String {
        switch self {
        case .normal: "Normal"
        case .upper: "Upper"
        case .baby: "Baby"
        case .third: "Third"
        case .thirdUpper: "Third_Upper"
        case .thirdBaby: "Third_Baby"
        case .fourth: "Fourth"
        }
    }
}

extension Set where Element == ItemClass {
    public static let allUpper: Set<ItemClass> = [.upper, .thirdUpper, .fourth]
    public static let allBaby: Set<ItemClass> = [.baby, .thirdBaby]
    public static let allThird: Set<ItemClass> = [.third, .thirdUpper, .thirdBaby]

    public init(from dictionary: [String : Bool]) {
        self = []

        if dictionary.keys.contains("All") {
            formUnion(ItemClass.allCases)
        }
        if dictionary.keys.contains("All_Upper") {
            formUnion(Set<ItemClass>.allUpper)
        }
        if dictionary.keys.contains("All_Baby") {
            formUnion(Set<ItemClass>.allBaby)
        }
        if dictionary.keys.contains("All_Third") {
            formUnion(Set<ItemClass>.allThird)
        }

        for (key, value) in dictionary {
            if let itemClass = ItemClass(stringValue: key) {
                if value {
                    insert(itemClass)
                } else {
                    remove(itemClass)
                }
            }
        }
    }
}
