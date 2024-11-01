//
//  ConsoleView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/10/24.
//

import SwiftUI

struct ConsoleView: View {
    var messages: [AttributedString]

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(0..<messages.count, id: \.self) { index in
                        Text(messages[index])
                            .id(index)
                            .lineLimit(1)
                    }
                }
            }
            .onAppear {
                proxy.scrollTo(messages.count - 1)
            }
            .onChange(of: messages.count) {
                proxy.scrollTo(messages.count - 1)
            }
        }
    }
}

#Preview {
    ConsoleView(messages: [
        "                                                                      ",
        "                   rAthena Development Team presents                  ",
        "                      ___   __  __                                    ",
        "                _____/   | / /_/ /_  ___  ____  ____ _                ",
        "               / ___/ /| |/ __/ __ \\/ _ \\/ __ \\/ __ `/             ",
        "              / /  / ___ / /_/ / / /  __/ / / / /_/ /                 ",
        "             /_/  /_/  |_\\__/_/ /_/\\___/_/ /_/\\__,_/               ",
        "                                                                      ",
        "                     http://rathena.org/board/                        ",
        "                                                                      ",
    ])
}
