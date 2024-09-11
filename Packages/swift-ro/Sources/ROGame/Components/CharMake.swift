//
//  CharMake.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/10.
//

import RONetwork
import SwiftUI

struct CharMake: View {
    var slot: UInt8

    @Environment(\.gameSession) private var gameSession

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
                ROImage("win_make")

                TextField("", text: $name)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .frame(width: 101, height: 18)
                    .offset(x: 61, y: 244)

                VStack {
                    Spacer()

                    HStack(spacing: 3) {
                        Spacer()

                        ROButton("btn_make") {
                            var char = CharInfo()
                            char.name = name
                            char.str = str
                            char.agi = agi
                            char.vit = vit
                            char.int = int
                            char.dex = dex
                            char.luk = luk
                            char.slot = slot

                            gameSession.makeChar(char: char)
                        }

                        ROButton("btn_cancel") {
                        }
                    }
                    .padding(.horizontal, 5)
                    .padding(.vertical, 4)
                }
            }
            .frame(width: 576, height: 342)
        }
    }
}

#Preview {
    CharMake(slot: 0)
}
