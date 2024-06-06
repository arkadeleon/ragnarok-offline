//
//  WeaponType.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/10.
//

import rAthenaCommon

public enum WeaponType: String, CaseIterable, CodingKey, Decodable {
    case fist = "Fist"
    case dagger = "Dagger"
    case oneHandedSword = "1hSword"
    case twoHandedSword = "2hSword"
    case oneHandedSpear = "1hSpear"
    case twoHandedSpear = "2hSpear"
    case oneHandedAxe = "1hAxe"
    case twoHandedAxe = "2hAxe"
    case mace = "Mace"
    case twoHandedMace = "2hMace"
    case staff = "Staff"
    case bow = "Bow"
    case knuckle = "Knuckle"
    case musical = "Musical"
    case whip = "Whip"
    case book = "Book"
    case katar = "Katar"
    case revolver = "Revolver"
    case rifle = "Rifle"
    case gatling = "Gatling"
    case shotgun = "Shotgun"
    case grenade = "Grenade"
    case huuma = "Huuma"
    case twoHandedStaff = "2hStaff"
}

extension WeaponType: Identifiable {
    public var id: Int {
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
        }
    }
}

extension WeaponType: CustomLocalizedStringResourceConvertible {
    public var localizedStringResource: LocalizedStringResource {
        switch self {
        case .fist: "Fist"
        case .dagger: "Dagger"
        case .oneHandedSword: "One-Handed Sword"
        case .twoHandedSword: "Two-Handed Sword"
        case .oneHandedSpear: "One-Handed Spear"
        case .twoHandedSpear: "Two-Handed Spear"
        case .oneHandedAxe: "One-Handed Axe"
        case .twoHandedAxe: "Two-Handed Axe"
        case .mace: "Mace"
        case .twoHandedMace: "Two-Handed Mace"
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
        case .twoHandedStaff: "Two-Handed Staff"
        }
    }
}
