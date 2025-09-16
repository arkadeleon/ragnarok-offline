//
//  CharSelectView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/10.
//

import NetworkPackets
import ROGame
import SwiftUI

struct CharSelectView: View {
    var chars: [CharInfo]

    @Environment(GameSession.self) private var gameSession

    @State private var slot1: CharInfo?
    @State private var slot2: CharInfo?
    @State private var slot3: CharInfo?

    @State private var selectedSlot: UInt8?

    private var selectedChar: CharInfo? {
        guard let selectedSlot else {
            return nil
        }

        switch selectedSlot {
        case 0:
            return slot1
        case 1:
            return slot2
        case 2:
            return slot3
        default:
            return nil
        }
    }

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            ZStack(alignment: .topLeading) {
                GameImage("login_interface/win_select.bmp")

                Button {
                    selectedSlot = 0
                } label: {
                    Text(slot1?.name ?? "Empty")
                        .gameText()
                }
                .buttonStyle(.borderless)
                .frame(width: 139, height: 144)
                .offset(x: 60, y: 44)

                Button {
                    selectedSlot = 1
                } label: {
                    Text(slot2?.name ?? "Empty")
                        .gameText()
                }
                .buttonStyle(.borderless)
                .frame(width: 139, height: 144)
                .offset(x: 224, y: 44)

                Button {
                    selectedSlot = 2
                } label: {
                    Text(slot3?.name ?? "Empty")
                        .gameText()
                }
                .buttonStyle(.borderless)
                .frame(width: 139, height: 144)
                .offset(x: 386, y: 44)

                if let selectedChar {
                    VStack(spacing: 1) {
                        Group {
                            Text(selectedChar.name)
                            Text(selectedChar.job.formatted())
                            Text(selectedChar.baseLevel.formatted())
                            Text(selectedChar.baseExp.formatted())
                            Text(selectedChar.hp.formatted())
                            Text(selectedChar.sp.formatted())
                        }
                        .gameText()
                        .frame(width: 95, height: 15)
                    }
                    .offset(x: 65, y: 204)

                    VStack(spacing: 1) {
                        Group {
                            Text(selectedChar.str.formatted())
                            Text(selectedChar.agi.formatted())
                            Text(selectedChar.vit.formatted())
                            Text(selectedChar.int.formatted())
                            Text(selectedChar.dex.formatted())
                            Text(selectedChar.luk.formatted())
                        }
                        .gameText()
                        .frame(width: 95, height: 15)
                    }
                    .offset(x: 209, y: 204)
                }

                VStack {
                    Spacer()

                    HStack(spacing: 3) {
                        if let selectedChar {
                            GameButton("btn_del.bmp") {
                            }
                        }

                        Spacer()

                        if let selectedSlot, selectedChar == nil {
                            GameButton("btn_make.bmp") {
                                gameSession.makeChar(slot: selectedSlot)
                            }
                        }

                        if let selectedChar {
                            GameButton("btn_ok.bmp") {
                                gameSession.selectChar(char: selectedChar)
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
        }
        .task {
            slot1 = chars.count > 0 ? chars[0] : nil
            slot2 = chars.count > 1 ? chars[1] : nil
            slot3 = chars.count > 2 ? chars[2] : nil
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

    CharSelectView(chars: [char])
        .padding()
        .environment(GameSession.previewing)
}
