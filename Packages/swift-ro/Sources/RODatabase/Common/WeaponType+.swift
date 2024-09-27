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
        case .fist: .init("Fist", bundle: .module)
        case .dagger: .init("Dagger", bundle: .module)
        case ._1hsword: .init("One-Handed Sword", bundle: .module)
        case ._2hsword: .init("Two-Handed Sword", bundle: .module)
        case ._1hspear: .init("One-Handed Spear", bundle: .module)
        case ._2hspear: .init("Two-Handed Spear", bundle: .module)
        case ._1haxe: .init("One-Handed Axe", bundle: .module)
        case ._2haxe: .init("Two-Handed Axe", bundle: .module)
        case .mace: .init("Mace", bundle: .module)
        case ._2hmace: .init("Two-Handed Mace", bundle: .module)
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
        case ._2hstaff: .init("Two-Handed Staff", bundle: .module)
        case .shield: .init("Shield", bundle: .module)
        }
    }
}
