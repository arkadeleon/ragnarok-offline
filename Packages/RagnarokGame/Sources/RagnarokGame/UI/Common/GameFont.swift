//
//  GameFont.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/1/22.
//

import SwiftUI

extension Font {
    static func game(size: CGFloat = 12, weight: Font.Weight? = nil) -> Font {
        if let weight {
            .custom("Arial", fixedSize: size).weight(weight)
        } else {
            .custom("Arial", fixedSize: size)
        }
    }
}
