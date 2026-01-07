//
//  CharacterMakeView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2024/9/10.
//

import RagnarokModels
import RagnarokSprite
import SwiftUI

struct CharacterMakeView: View {
    var slot: Int

    @Environment(GameSession.self) private var gameSession

    @State private var character = CharacterInfo()
    @State private var characterAnimation: SpriteRenderer.Animation?

    var body: some View {
        ZStack(alignment: .topLeading) {
            GameImage("login_interface/win_make.bmp")

            TextField(String(), text: $character.name)
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
                    if character.headPalette == 8 {
                        character.headPalette = 0
                    } else {
                        character.headPalette += 1
                    }
                }
                .offset(x: 87, y: 105)

                GameButton("scroll1left.bmp") {
                    character.head -= 1
                }
                .offset(x: 47, y: 135)
                .disabled(character.head == 0)

                GameButton("scroll1right.bmp") {
                    character.head += 1
                }
                .offset(x: 127, y: 135)
                .disabled(character.head == 12)
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
                    if character.str != 9 {
                        character.str += 1
                        character.int -= 1
                    }
                }
                .offset(x: 270, y: 50)

                GameButton("login_interface/arw-agi0.bmp") {
                    if character.agi != 9 {
                        character.agi += 1
                        character.luk -= 1
                    }
                }
                .offset(x: 191, y: 103)

                GameButton("login_interface/arw-vit0.bmp") {
                    if character.vit != 9 {
                        character.vit += 1
                        character.dex -= 1
                    }
                }
                .offset(x: 348, y: 104)

                GameButton("login_interface/arw-int0.bmp") {
                    if character.int != 9 {
                        character.int += 1
                        character.str -= 1
                    }
                }
                .offset(x: 270, y: 243)

                GameButton("login_interface/arw-dex0.bmp") {
                    if character.dex != 9 {
                        character.dex += 1
                        character.vit -= 1
                    }
                }
                .offset(x: 191, y: 190)

                GameButton("login_interface/arw-luk0.bmp") {
                    if character.luk != 9 {
                        character.luk += 1
                        character.agi -= 1
                    }
                }
                .offset(x: 348, y: 190)
            }
            .frame(width: 36, height: 36)

            Canvas { context, size in
                let str = Double(character.str + 1) / 10 * size.height / 2
                let agi = Double(character.agi + 1) / 10 * size.height / 2
                let vit = Double(character.vit + 1) / 10 * size.height / 2
                let int = Double(character.int + 1) / 10 * size.height / 2
                let dex = Double(character.dex + 1) / 10 * size.height / 2
                let luk = Double(character.luk + 1) / 10 * size.height / 2

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
                    Text(character.str.formatted())
                    Text(character.agi.formatted())
                    Text(character.vit.formatted())
                    Text(character.int.formatted())
                    Text(character.dex.formatted())
                    Text(character.luk.formatted())
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
                    gameSession.charSession?.makeCharacter(character: character)
                }
                .disabled(character.name.isEmpty)

                GameButton("btn_cancel.bmp") {
                    gameSession.cancelMakeCharacter()
                }
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 4)
        }
        .task {
            character.job = 0           // Novice
            character.head = 0          // First hair style in the list
            character.headPalette = 0   // Default hair color
            character.str = 5
            character.agi = 5
            character.vit = 5
            character.int = 5
            character.dex = 5
            character.luk = 5
            character.charNum = slot

            if let account = gameSession.account {
                character.sex = account.sex
            }
        }
        .task(id: "\(character.head), \(character.headPalette)") {
            characterAnimation = await gameSession.characterAnimation(for: character)
        }
    }
}

#Preview {
    CharacterMakeView(slot: 0)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.testing)
}
