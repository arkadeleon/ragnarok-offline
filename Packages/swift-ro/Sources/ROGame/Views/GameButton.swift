//
//  GameButton.swift
//  RagnarokOffline
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
    }

    init(_ imageName: String, action: @escaping () -> Void) {
        self.imageName = imageName
        self.action = action
    }
}

struct GameButtonStyle: ButtonStyle {
    var imageName: String
    var pressedImageName: String

    init(_ imageName: String, pressed pressedImageName: String) {
        self.imageName = imageName
        self.pressedImageName = pressedImageName
    }

    func makeBody(configuration: Configuration) -> some View {
        if configuration.isPressed {
            GameImage(pressedImageName)
        } else {
            GameImage(imageName)
        }
    }
}

extension ButtonStyle where Self == GameButtonStyle {
    static func game(_ imageName: String, pressed pressedImageName: String) -> GameButtonStyle {
        GameButtonStyle(imageName, pressed: pressedImageName)
    }
}

#Preview {
    GameButton("btn_ok.bmp") {
    }
}
