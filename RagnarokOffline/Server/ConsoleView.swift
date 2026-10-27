//
//  ConsoleView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/10/24.
//

import SwiftUI

struct ConsoleView: View {
    var messages: [AttributedString]

    @State private var scrollPosition = ScrollPosition(edge: .bottom)
    @State private var isAtBottom = true

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(0..<messages.count, id: \.self) { index in
                    Text(messages[index])
                        .id(index)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal)
        }
        .scrollPosition($scrollPosition)
        .onScrollGeometryChange(for: ScrollGeometry.self) { geometry in
            geometry
        } action: { oldGeometry, newGeometry in
            if isAtBottom && (oldGeometry.containerSize != newGeometry.containerSize || oldGeometry.contentSize != newGeometry.contentSize) {
                scrollPosition.scrollTo(edge: .bottom)
            } else {
                isAtBottom = newGeometry.visibleRect.maxY >= newGeometry.contentSize.height + newGeometry.contentInsets.bottom - 1
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
