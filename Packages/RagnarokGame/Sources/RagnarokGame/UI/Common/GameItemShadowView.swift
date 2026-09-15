//
//  GameItemShadowView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/9/16.
//

import SwiftUI

struct GameItemShadowView: View {
    var body: some View {
        Ellipse()
            .fill(Color(#colorLiteral(red: 0.7176470588, green: 0.7607843137, blue: 0.8470588235, alpha: 1)))
            .blur(radius: 1.5)
            .frame(width: 25, height: 12)
    }
}

#Preview {
    GameItemShadowView()
        .padding()
}
