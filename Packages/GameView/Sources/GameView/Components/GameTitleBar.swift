//
//  GameTitleBar.swift
//  GameView
//
//  Created by Leon Li on 2025/4/11.
//

import GameCore
import SwiftUI

struct GameTitleBar: View {
    var body: some View {
        HStack(spacing: 0) {
            GameImage("basic_interface/titlebar_left.bmp")

            GameImage("basic_interface/titlebar_mid.bmp") { image in
                image.resizable()
            }

            GameImage("basic_interface/titlebar_right.bmp")
        }
        .frame(height: 17)
    }
}

#Preview {
    GameTitleBar()
        .frame(width: 280)
        .padding()
        .environment(GameSession.previewing)
}
