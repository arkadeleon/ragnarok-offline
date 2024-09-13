//
//  WeaponType.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/10.
//

import rAthenaCommon

public enum WeaponType: Option, CodingKeyRepresentable {
    case fist
    case dagger
    case oneHandedSword
    case twoHandedSword
    case oneHandedSpear
    case twoHandedSpear
    case oneHandedAxe
    case twoHandedAxe
    case mace
    case twoHandedMace
    case staff
    case bow
    case knuckle
    case musical
    case whip
    case book
    case katar
    case revolver
    case rifle
    case gatling
    case shotgun
    case grenade
    case huuma
    case twoHandedStaff
    case shield

    public var intValue: Int {
        switch self {
        case .fist: RA_W_FIST
        case .dagger: RA_W_DAGGER
        case .oneHandedSword: RA_W_1HSWORD
        case .twoHandedSword: RA_W_2HSWORD
        case .oneHandedSpear: RA_W_1HSPEAR
        case .twoHandedSpear: RA_W_2HSPEAR
        case .oneHandedAxe: RA_W_1HAXE
        case .twoHandedAxe: RA_W_2HAXE
        case .mace: RA_W_MACE
        case .twoHandedMace: RA_W_2HMACE
        case .staff: RA_W_STAFF
        case .bow: RA_W_BOW
        case .knuckle: RA_W_KNUCKLE
        case .musical: RA_W_MUSICAL
        case .whip: RA_W_WHIP
        case .book: RA_W_BOOK
        case .katar: RA_W_KATAR
        case .revolver: RA_W_REVOLVER
        case .rifle: RA_W_RIFLE
        case .gatling: RA_W_GATLING
        case .shotgun: RA_W_SHOTGUN
        case .grenade: RA_W_GRENADE
        case .huuma: RA_W_HUUMA
        case .twoHandedStaff: RA_W_2HSTAFF
        case .shield: RA_W_SHIELD
        }
    }

    public var stringValue: String {
        switch self {
        case .fist: "Fist"
        case .dagger: "Dagger"
        case .oneHandedSword: "1hSword"
        case .twoHandedSword: "2hSword"
        case .oneHandedSpear: "1hSpear"
        case .twoHandedSpear: "2hSpear"
        case .oneHandedAxe: "1hAxe"
        case .twoHandedAxe: "2hAxe"
        case .mace: "Mace"
        case .twoHandedMace: "2hMace"
        case .staff: "Staff"
        case .bow: "Bow"
        case .knuckle: "Knuckle"
        case .musical: "Musical"
        case .whip: "Whip"
        case .book: "Book"
        case .katar: "Katar"
        case .revolver: "Revolver"
        case .rifle: "Rifle"
        case .gatling: "Gatling"
        case .shotgun: "Shotgun"
        case .grenade: "Grenade"
        case .huuma: "Huuma"
        case .twoHandedStaff: "2hStaff"
        case .shield: "Shield"
        }
    }

    public var codingKey: any CodingKey {
        AnyCodingKey(stringValue: stringValue)
    }

    public init?<T>(codingKey: T) where T: CodingKey {
        self.init(stringValue: codingKey.stringValue)
    }
}

extension WeaponType: CustomLocalizedStringResourceConvertible {
    public var localizedStringResource: LocalizedStringResource {
        switch self {
        case .fist: .init("Fist", bundle: .module)
        case .dagger: .init("Dagger", bundle: .module)
        case .oneHandedSword: .init("One-Handed Sword", bundle: .module)
        case .twoHandedSword: .init("Two-Handed Sword", bundle: .module)
        case .oneHandedSpear: .init("One-Handed Spear", bundle: .module)
        case .twoHandedSpear: .init("Two-Handed Spear", bundle: .module)
        case .oneHandedAxe: .init("One-Handed Axe", bundle: .module)
        case .twoHandedAxe: .init("Two-Handed Axe", bundle: .module)
        case .mace: .init("Mace", bundle: .module)
        case .twoHandedMace: .init("Two-Handed Mace", bundle: .module)
        case .staff: .init("Staff", bundle: .module)
        case .bow: .init("Bow", bundle: .module)
        case .knuckle: .init("Knuckle", bundle: .module)
        case .musical: .init("Musical", bundle: .module)
        case .whip: .init("Whip", bundle: .module)
        case .book: .init("Book", bundle: .module)
        case .katar: .init("Katar", bundle: .module)
        case .revolver: .init("Revolver", bundle: .module)
        case .rifle: .init("Rifle", bundle: .module)
        case .gatling: .init("Gatling", bundle: .module)
        case .shotgun: .init("Shotgun", bundle: .module)
        case .grenade: .init("Grenade", bundle: .module)
        case .huuma: .init("Huuma", bundle: .module)
        case .twoHandedStaff: .init("Two-Handed Staff", bundle: .module)
        case .shield: .init("Shield", bundle: .module)
        }
    }
}
