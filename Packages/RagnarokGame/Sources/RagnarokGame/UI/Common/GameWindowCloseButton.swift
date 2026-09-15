//
//  GameWindowCloseButton.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/14.
//

import SwiftUI

struct GameWindowCloseButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Capsule()
                    .frame(width: 8, height: 1.5)
                    .rotationEffect(.degrees(45))
                Capsule()
                    .frame(width: 8, height: 1.5)
                    .rotationEffect(.degrees(-45))
            }
        }
        .buttonStyle(.gameTitleBar)
    }
}

#Preview {
    GameWindowCloseButton {
        // close action
    }
    .padding()
}
