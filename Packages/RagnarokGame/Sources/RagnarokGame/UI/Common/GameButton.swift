//
//  GameButton.swift
//  RagnarokGame
//
//  Created by Leon Li on 2024/9/9.
//

import SwiftUI

struct GameButton: View {
    var imageName: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            GameImage(imageName)
        }
        .buttonStyle(.plain)
    }

    init(_ imageName: String, action: @escaping () -> Void) {
        self.imageName = imageName
        self.action = action
    }
}

#Preview {
    GameButton("btn_ok.bmp") {
    }
    .environment(GameSession.testing)
}
