//
//  CharSelectView.swift
//  GameView
//
//  Created by Leon Li on 2024/9/10.
//

import GameCore
import NetworkPackets
import SpriteRendering
import SwiftUI

struct CharSelectView: View {
    var chars: [CharInfo]

    @Environment(GameSession.self) private var gameSession

    @State private var character1: CharInfo?
    @State private var characterAnimation1: SpriteRenderer.Animation?

    @State private var character2: CharInfo?
    @State private var characterAnimation2: SpriteRenderer.Animation?

    @State private var character3: CharInfo?
    @State private var characterAnimation3: SpriteRenderer.Animation?

    @State private var selectedSlot: UInt8?

    private var selectedCharacter: CharInfo? {
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
                        Text(selectedCharacter.baseLevel.formatted())
                        Text(selectedCharacter.baseExp.formatted())
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

            VStack {
                Spacer()

                HStack(spacing: 3) {
                    if let selectedCharacter {
                        GameButton("btn_del.bmp") {
                        }
                        .disabled(true)
                    }

                    Spacer()

                    if let selectedSlot, selectedCharacter == nil {
                        GameButton("btn_make.bmp") {
                            gameSession.makeChar(slot: selectedSlot)
                        }
                    }

                    if let selectedCharacter {
                        GameButton("btn_ok.bmp") {
                            gameSession.selectChar(char: selectedCharacter)
                        }
                    }

                    GameButton("btn_cancel.bmp") {
                    }
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 4)
            }
        }
        .frame(width: 576, height: 342)
        .task {
            character1 = chars.count > 0 ? chars[0] : nil
            characterAnimation1 = await gameSession.characterAnimation(forSlot: 0)
        }
        .task {
            character2 = chars.count > 1 ? chars[1] : nil
            characterAnimation2 = await gameSession.characterAnimation(forSlot: 1)
        }
        .task {
            character3 = chars.count > 2 ? chars[2] : nil
            characterAnimation3 = await gameSession.characterAnimation(forSlot: 2)
        }
    }
}

#Preview {
    let char = {
        var char = CharInfo()
        char.name = "Leon"
        char.str = 1
        char.agi = 1
        char.vit = 1
        char.int = 1
        char.dex = 1
        char.luk = 1
        return char
    }()

    ZStack {
        GameImage("bgi_temp.bmp") { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
        .ignoresSafeArea()

        CharSelectView(chars: [char])
    }
    .environment(GameSession.previewing)
}
