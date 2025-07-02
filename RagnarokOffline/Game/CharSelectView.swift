//
//  CharSelectView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/10.
//

import ROGame
import ROPackets
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
                    GameText(slot1?.name ?? "Empty")
                }
                .buttonStyle(.plain)
                .frame(width: 139, height: 144)
                .offset(x: 60, y: 44)

                Button {
                    selectedSlot = 1
                } label: {
                    GameText(slot2?.name ?? "Empty")
                }
                .buttonStyle(.plain)
                .frame(width: 139, height: 144)
                .offset(x: 224, y: 44)

                Button {
                    selectedSlot = 2
                } label: {
                    GameText(slot3?.name ?? "Empty")
                }
                .buttonStyle(.plain)
                .frame(width: 139, height: 144)
                .offset(x: 386, y: 44)

                if let selectedChar {
                    VStack(spacing: 1) {
                        Group {
                            GameText(selectedChar.name)
                            GameText(selectedChar.job.formatted())
                            GameText(selectedChar.baseLevel.formatted())
                            GameText(selectedChar.baseExp.formatted())
                            GameText(selectedChar.hp.formatted())
                            GameText(selectedChar.sp.formatted())
                        }
                        .frame(width: 95, height: 15)
                    }
                    .offset(x: 65, y: 204)

                    VStack(spacing: 1) {
                        Group {
                            GameText(selectedChar.str.formatted())
                            GameText(selectedChar.agi.formatted())
                            GameText(selectedChar.vit.formatted())
                            GameText(selectedChar.int.formatted())
                            GameText(selectedChar.dex.formatted())
                            GameText(selectedChar.luk.formatted())
                        }
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
        .environment(GameSession())
}
