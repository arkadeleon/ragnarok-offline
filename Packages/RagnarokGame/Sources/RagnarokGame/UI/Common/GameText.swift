//
//  GameText.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/4/6.
//

import SwiftUI

struct GameText: ViewModifier {
    var size: CGFloat
    var color: Color

    func body(content: Content) -> some View {
        content
            .font(.custom("Arial", fixedSize: size))
            .foregroundStyle(color)
    }
}

extension View {
    func gameText(size: CGFloat = 12, color: Color = .black) -> some View {
        modifier(GameText(size: size, color: color))
    }
}

#Preview {
    Text(verbatim: "Novice")
        .gameText()
}
