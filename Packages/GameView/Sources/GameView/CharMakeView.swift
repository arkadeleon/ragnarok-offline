//
//  CharMakeView.swift
//  GameView
//
//  Created by Leon Li on 2024/9/10.
//

import GameCore
import NetworkPackets
import SpriteRendering
import SwiftUI

struct CharMakeView: View {
    var slot: UInt8

    @Environment(GameSession.self) private var gameSession

    @State private var char = CharInfo()
    @State private var characterAnimation: SpriteRenderer.Animation?

    var body: some View {
        ZStack(alignment: .topLeading) {
            GameImage("login_interface/win_make.bmp")

            TextField(String(), text: $char.name)
                .textFieldStyle(.plain)
                #if !os(macOS)
                .textInputAutocapitalization(.never)
                #endif
                .disableAutocorrection(true)
                .gameText()
                .frame(width: 97, height: 18)
                .offset(x: 63, y: 244)

            Group {
                GameButton("scroll0up.bmp") {
                    if char.headPalette == 8 {
                        char.headPalette = 0
                    } else {
                        char.headPalette += 1
                    }
                }
                .offset(x: 87, y: 105)

                GameButton("scroll1left.bmp") {
                    char.head -= 1
                }
                .offset(x: 47, y: 135)
                .disabled(char.head == 0)

                GameButton("scroll1right.bmp") {
                    char.head += 1
                }
                .offset(x: 127, y: 135)
                .disabled(char.head == 12)
            }
            .frame(width: 13, height: 13)

            Canvas { context, size in
                if let characterAnimation, let firstFrame = characterAnimation.firstFrame {
                    var rect = CGRect(x: 0, y: 0, width: characterAnimation.frameWidth, height: characterAnimation.frameHeight)
                    rect.origin.x = (size.width - characterAnimation.frameWidth) / 2
                    rect.origin.y = (size.height - characterAnimation.frameHeight) / 2
                    context.draw(Image(decorative: firstFrame, scale: 2), in: rect)
                }
            }
            .frame(width: 65, height: 110)
            .offset(x: 62, y: 120)

            Group {
                GameButton("login_interface/arw-str0.bmp") {
                    if char.str != 9 {
                        char.str += 1
                        char.int -= 1
                    }
                }
                .offset(x: 270, y: 50)

                GameButton("login_interface/arw-agi0.bmp") {
                    if char.agi != 9 {
                        char.agi += 1
                        char.luk -= 1
                    }
                }
                .offset(x: 191, y: 103)

                GameButton("login_interface/arw-vit0.bmp") {
                    if char.vit != 9 {
                        char.vit += 1
                        char.dex -= 1
                    }
                }
                .offset(x: 348, y: 104)

                GameButton("login_interface/arw-int0.bmp") {
                    if char.int != 9 {
                        char.int += 1
                        char.str -= 1
                    }
                }
                .offset(x: 270, y: 243)

                GameButton("login_interface/arw-dex0.bmp") {
                    if char.dex != 9 {
                        char.dex += 1
                        char.vit -= 1
                    }
                }
                .offset(x: 191, y: 190)

                GameButton("login_interface/arw-luk0.bmp") {
                    if char.luk != 9 {
                        char.luk += 1
                        char.agi -= 1
                    }
                }
                .offset(x: 348, y: 190)
            }
            .frame(width: 36, height: 36)

            Canvas { context, size in
                let str = Double(char.str + 1) / 10 * size.height / 2
                let agi = Double(char.agi + 1) / 10 * size.height / 2
                let vit = Double(char.vit + 1) / 10 * size.height / 2
                let int = Double(char.int + 1) / 10 * size.height / 2
                let dex = Double(char.dex + 1) / 10 * size.height / 2
                let luk = Double(char.luk + 1) / 10 * size.height / 2

                let sin60: Double = sin(60 * .pi / 180)
                let cos60: Double = cos(60 * .pi / 180)

                context.translateBy(x: size.width / 2, y: size.height / 2)

                // Draw in counter-clockwise from str
                var path = Path()
                path.move(to: CGPoint(x: 0, y: -str))
                path.addLine(to: CGPoint(x: -agi * sin60, y: -agi * cos60))
                path.addLine(to: CGPoint(x: -dex * sin60, y: dex * cos60))
                path.addLine(to: CGPoint(x: 0, y: int))
                path.addLine(to: CGPoint(x: luk * sin60, y: luk * cos60))
                path.addLine(to: CGPoint(x: vit * sin60, y: -vit * cos60))
                path.closeSubpath()

                context.fill(path, with: .color(Color(#colorLiteral(red: 0.4823529412, green: 0.5803921569, blue: 0.8078431373, alpha: 1))))
            }
            .frame(width: 158, height: 158)
            .offset(x: 209, y: 86)

            VStack(spacing: 1) {
                Group {
                    Text(char.str.formatted())
                    Text(char.agi.formatted())
                    Text(char.vit.formatted())
                    Text(char.int.formatted())
                    Text(char.dex.formatted())
                    Text(char.luk.formatted())
                }
                .gameText()
                .frame(width: 95, height: 15)
            }
            .offset(x: 460, y: 39)
        }
        .frame(width: 576, height: 342)
        .overlay(alignment: .bottomTrailing) {
            HStack(spacing: 3) {
                GameButton("btn_make.bmp") {
                    gameSession.makeChar(char: char)
                }
                .disabled(char.name.isEmpty)

                GameButton("btn_cancel.bmp") {
                    gameSession.cancelMakeChar()
                }
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 4)
        }
        .task {
            char.job = 0            // Novice
            char.head = 0           // First hair style in the list
            char.headPalette = 0    // Default hair color
            char.str = 5
            char.agi = 5
            char.vit = 5
            char.int = 5
            char.dex = 5
            char.luk = 5
            char.charNum = slot

            if let account = gameSession.account {
                char.sex = account.sex
            }
        }
        .task(id: "\(char.head), \(char.headPalette)") {
            characterAnimation = await gameSession.characterAnimation(for: char)
        }
    }
}

#Preview {
    CharMakeView(slot: 0)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.previewing)
}
