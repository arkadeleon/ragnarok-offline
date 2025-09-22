//
//  GameBottomBar.swift
//  GameView
//
//  Created by Leon Li on 2025/4/16.
//

import GameCore
import SwiftUI

struct GameBottomBar: View {
    var body: some View {
        HStack(spacing: 0) {
            GameImage("basic_interface/btnbar_left.bmp")

            GameImage("basic_interface/btnbar_mid.bmp") { image in
                image.resizable()
            }

            GameImage("basic_interface/btnbar_right.bmp")
        }
        .frame(height: 21)
    }
}

#Preview {
    GameBottomBar()
        .frame(width: 280)
        .padding()
        .environment(GameSession.previewing)
}
