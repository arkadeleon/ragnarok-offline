//
//  GameWindow.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/11.
//

import SwiftUI

struct GameWindow<Content, TitleBar, BottomBar>: View where Content: View, TitleBar: View, BottomBar: View {
    @ViewBuilder var content: () -> Content
    @ViewBuilder var titleBar: () -> TitleBar
    @ViewBuilder var bottomBar: () -> BottomBar

    @Environment(\.displayScale) private var displayScale

    var body: some View {
        VStack(spacing: 0) {
            titleBar()

            content()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .overlay(alignment: .leading) {
                    Rectangle().fill(Color.gameBoxBorder).frame(width: 1 / displayScale)
                }
                .overlay(alignment: .trailing) {
                    Rectangle().fill(Color.gameBoxBorder).frame(width: 1 / displayScale)
                }

            bottomBar()
        }
    }

    init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder titleBar: @escaping () -> TitleBar,
        @ViewBuilder bottomBar: @escaping () -> BottomBar
    ) {
        self.content = content
        self.titleBar = titleBar
        self.bottomBar = bottomBar
    }

    init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder titleBar: @escaping () -> TitleBar
    ) where BottomBar == GameBottomBar {
        self.init(
            content: content,
            titleBar: titleBar,
            bottomBar: {
                GameBottomBar()
            }
        )
    }

    init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder bottomBar: @escaping () -> BottomBar
    ) where TitleBar == GameTitleBar {
        self.init(
            content: content,
            titleBar: {
                GameTitleBar()
            },
            bottomBar: bottomBar
        )
    }

    init(
        @ViewBuilder content: @escaping () -> Content
    ) where TitleBar == GameTitleBar, BottomBar == GameBottomBar {
        self.init(
            content: content,
            titleBar: {
                GameTitleBar()
            },
            bottomBar: {
                GameBottomBar()
            }
        )
    }
}
