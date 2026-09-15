//
//  GameCharacterShadowView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/9/16.
//

import SwiftUI

struct GameCharacterShadowView: View {
    var body: some View {
        Ellipse()
            .fill(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.4)))
            .blur(radius: 2)
            .frame(width: 36, height: 24)
    }
}

#Preview {
    GameCharacterShadowView()
        .padding()
}
