//
//  CharMakeView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/10.
//

import ROPackets
import SwiftUI

struct CharMakeView: View {
    var slot: UInt8
    var onMakeChar: (CharInfo) -> Void

    @State private var name = ""
    @State private var str: UInt8 = 1
    @State private var agi: UInt8 = 1
    @State private var vit: UInt8 = 1
    @State private var int: UInt8 = 1
    @State private var dex: UInt8 = 1
    @State private var luk: UInt8 = 1

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            ZStack(alignment: .topLeading) {
                GameImage("login_interface/win_make.bmp")

                TextField(String(), text: $name)
                    .textFieldStyle(.plain)
                    .font(.custom("Arial", fixedSize: 12))
                    #if !os(macOS)
                    .textInputAutocapitalization(.never)
                    #endif
                    .disableAutocorrection(true)
                    .frame(width: 101, height: 18)
                    .offset(x: 61, y: 244)

                VStack {
                    Spacer()

                    HStack(spacing: 3) {
                        Spacer()

                        GameButton("btn_make.bmp") {
                            var char = CharInfo()
                            char.name = name
                            char.str = str
                            char.agi = agi
                            char.vit = vit
                            char.int = int
                            char.dex = dex
                            char.luk = luk
                            char.slot = slot

                            onMakeChar(char)
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
    }

    init(slot: UInt8, onMakeChar: @escaping (CharInfo) -> Void) {
        self.slot = slot
        self.onMakeChar = onMakeChar
    }
}

#Preview {
    CharMakeView(slot: 0) { char in
        // Make char.
    }
    .padding()
}
