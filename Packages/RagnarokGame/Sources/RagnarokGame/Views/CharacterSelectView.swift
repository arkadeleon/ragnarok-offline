//
//  CharacterSelectView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2024/9/10.
//

import RagnarokNetwork
import RagnarokSprite
import SwiftUI

struct CharacterSelectView: View {
    var characters: [CharacterInfo]

    @Environment(GameSession.self) private var gameSession

    @State private var character1: CharacterInfo?
    @State private var characterAnimation1: SpriteRenderer.Animation?

    @State private var character2: CharacterInfo?
    @State private var characterAnimation2: SpriteRenderer.Animation?

    @State private var character3: CharacterInfo?
    @State private var characterAnimation3: SpriteRenderer.Animation?

    @State private var selectedSlot: Int?

    private var selectedCharacter: CharacterInfo? {
        guard let selectedSlot else {
            return nil
        }

        switch selectedSlot {
        case 0:
            return character1
        case 1:
            return character2
        case 2:
            return character3
        default:
            return nil
        }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            GameImage("login_interface/win_select.bmp")

            Button {
                selectedSlot = 0
            } label: {
                ZStack {
                    if selectedSlot == 0 {
                        GameImage("login_interface/box_select.bmp")
                    }

                    if let image = characterAnimation1?.firstFrame {
                        Image(decorative: image, scale: 2)
                            .offset(y: 10)
                    }
                }
                .frame(width: 139, height: 144)
            }
            .buttonStyle(.borderless)
            .offset(x: 56, y: 40)

            Button {
                selectedSlot = 1
            } label: {
                ZStack {
                    if selectedSlot == 1 {
                        GameImage("login_interface/box_select.bmp")
                    }

                    if let image = characterAnimation2?.firstFrame {
                        Image(decorative: image, scale: 2)
                            .offset(y: 10)
                    }
                }
                .frame(width: 139, height: 144)
            }
            .buttonStyle(.borderless)
            .offset(x: 220, y: 40)

            Button {
                selectedSlot = 2
            } label: {
                ZStack {
                    if selectedSlot == 2 {
                        GameImage("login_interface/box_select.bmp")
                    }

                    if let image = characterAnimation3?.firstFrame {
                        Image(decorative: image, scale: 2)
                            .offset(y: 10)
                    }
                }
                .frame(width: 139, height: 144)
            }
            .buttonStyle(.borderless)
            .offset(x: 382, y: 40)

            if let selectedCharacter {
                VStack(spacing: 1) {
                    Group {
                        Text(selectedCharacter.name)
                        Text(selectedCharacter.job.formatted())
                        Text(selectedCharacter.level.formatted())
                        Text(selectedCharacter.exp.formatted())
                        Text(selectedCharacter.hp.formatted())
                        Text(selectedCharacter.sp.formatted())
                    }
                    .gameText()
                    .frame(width: 95, height: 15)
                }
                .offset(x: 65, y: 204)

                VStack(spacing: 1) {
                    Group {
                        Text(selectedCharacter.str.formatted())
                        Text(selectedCharacter.agi.formatted())
                        Text(selectedCharacter.vit.formatted())
                        Text(selectedCharacter.int.formatted())
                        Text(selectedCharacter.dex.formatted())
                        Text(selectedCharacter.luk.formatted())
                    }
                    .gameText()
                    .frame(width: 95, height: 15)
                }
                .offset(x: 209, y: 204)
            }
        }
        .frame(width: 576, height: 342)
        .overlay(alignment: .bottomLeading) {
            HStack(spacing: 3) {
                if let selectedCharacter {
                    GameButton("btn_del.bmp") {
                    }
                    .disabled(true)
                }
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 4)
        }
        .overlay(alignment: .bottomTrailing) {
            HStack(spacing: 3) {
                if let selectedSlot, selectedCharacter == nil {
                    GameButton("btn_make.bmp") {
                        gameSession.makeCharacter(slot: selectedSlot)
                    }
                }

                if let selectedCharacter {
                    GameButton("btn_ok.bmp") {
                        gameSession.charSession?.selectCharacter(slot: selectedCharacter.charNum)
                    }
                }

                GameButton("btn_cancel.bmp") {
                }
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 4)
        }
        .task {
            character1 = characters.count > 0 ? characters[0] : nil
            characterAnimation1 = await gameSession.characterAnimation(forSlot: 0)
        }
        .task {
            character2 = characters.count > 1 ? characters[1] : nil
            characterAnimation2 = await gameSession.characterAnimation(forSlot: 1)
        }
        .task {
            character3 = characters.count > 2 ? characters[2] : nil
            characterAnimation3 = await gameSession.characterAnimation(forSlot: 2)
        }
    }
}

#Preview {
    let character = {
        var character = CharacterInfo()
        character.name = "Leon"
        character.str = 1
        character.agi = 1
        character.vit = 1
        character.int = 1
        character.dex = 1
        character.luk = 1
        return character
    }()

    CharacterSelectView(characters: [character])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.testing)
}
