//
//  Race.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/9.
//

import rAthenaCommon

public enum Race: Option {
    case formless
    case undead
    case brute
    case plant
    case insect
    case fish
    case demon
    case demihuman
    case angel
    case dragon

    public var intValue: Int {
        switch self {
        case .formless: RA_RC_FORMLESS
        case .undead: RA_RC_UNDEAD
        case .brute: RA_RC_BRUTE
        case .plant: RA_RC_PLANT
        case .insect: RA_RC_INSECT
        case .fish: RA_RC_FISH
        case .demon: RA_RC_DEMON
        case .demihuman: RA_RC_DEMIHUMAN
        case .angel: RA_RC_ANGEL
        case .dragon: RA_RC_DRAGON
        }
    }

    public var stringValue: String {
        switch self {
        case .formless: "Formless"
        case .undead: "Undead"
        case .brute: "Brute"
        case .plant: "Plant"
        case .insect: "Insect"
        case .fish: "Fish"
        case .demon: "Demon"
        case .demihuman: "Demihuman"
        case .angel: "Angel"
        case .dragon: "Dragon"
        }
    }
}

extension Race: CustomLocalizedStringResourceConvertible {
    public var localizedStringResource: LocalizedStringResource {
        switch self {
        case .formless: .init("Formless", bundle: .module)
        case .undead: .init("Undead", bundle: .module)
        case .brute: .init("Brute", bundle: .module)
        case .plant: .init("Plant", bundle: .module)
        case .insect: .init("Insect", bundle: .module)
        case .fish: .init("Fish", bundle: .module)
        case .demon: .init("Demon", bundle: .module)
        case .demihuman: .init("Demi-Human", bundle: .module)
        case .angel: .init("Angel", bundle: .module)
        case .dragon: .init("Dragon", bundle: .module)
        }
    }
}
