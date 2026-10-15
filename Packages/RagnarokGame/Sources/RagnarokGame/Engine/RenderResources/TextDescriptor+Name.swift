//
//  TextDescriptor+Name.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/10/15.
//

import Foundation
import RagnarokModels

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension TextDescriptor {
    /// The name drops everything from `#` on, so `Kafra Employee#prt` reads `Kafra Employee`.
    init(name: String, objectType: MapObjectType) {
        let name = String(name.prefix(while: { $0 != "#" }))

        let color: SIMD3<Float> = switch objectType {
        case .monster, .abr, .bionic, .disguised:
            [1, 0.776, 0.776]
        case .npc, .npc2:
            [0.580, 0.741, 0.969]
        default:
            [1, 1, 1]
        }

        var text = AttributedString(name)
        #if canImport(UIKit)
        text.uiKit.foregroundColor = UIColor(red: CGFloat(color.x), green: CGFloat(color.y), blue: CGFloat(color.z), alpha: 1)
        #elseif canImport(AppKit)
        text.appKit.foregroundColor = NSColor(red: CGFloat(color.x), green: CGFloat(color.y), blue: CGFloat(color.z), alpha: 1)
        #endif

        self.init(text: text)
    }
}
