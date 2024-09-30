//
//  Race.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/1/9.
//

import Foundation
import ROGenerated

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
