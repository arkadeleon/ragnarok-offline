//
//  WeaponType+.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/10.
//

import Foundation
import ROGenerated

extension WeaponType: CustomLocalizedStringResourceConvertible {
    public var localizedStringResource: LocalizedStringResource {
        switch self {
        case .w_fist: .init("Fist", bundle: .module)
        case .w_dagger: .init("Dagger", bundle: .module)
        case .w_1hsword: .init("One-Handed Sword", bundle: .module)
        case .w_2hsword: .init("Two-Handed Sword", bundle: .module)
        case .w_1hspear: .init("One-Handed Spear", bundle: .module)
        case .w_2hspear: .init("Two-Handed Spear", bundle: .module)
        case .w_1haxe: .init("One-Handed Axe", bundle: .module)
        case .w_2haxe: .init("Two-Handed Axe", bundle: .module)
        case .w_mace: .init("Mace", bundle: .module)
        case .w_2hmace: .init("Two-Handed Mace", bundle: .module)
        case .w_staff: .init("Staff", bundle: .module)
        case .w_bow: .init("Bow", bundle: .module)
        case .w_knuckle: .init("Knuckle", bundle: .module)
        case .w_musical: .init("Musical", bundle: .module)
        case .w_whip: .init("Whip", bundle: .module)
        case .w_book: .init("Book", bundle: .module)
        case .w_katar: .init("Katar", bundle: .module)
        case .w_revolver: .init("Revolver", bundle: .module)
        case .w_rifle: .init("Rifle", bundle: .module)
        case .w_gatling: .init("Gatling", bundle: .module)
        case .w_shotgun: .init("Shotgun", bundle: .module)
        case .w_grenade: .init("Grenade", bundle: .module)
        case .w_huuma: .init("Huuma", bundle: .module)
        case .w_2hstaff: .init("Two-Handed Staff", bundle: .module)
        case .w_shield: .init("Shield", bundle: .module)
        }
    }
}
