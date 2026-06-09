//
//  GameWindow.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/11.
//

import SwiftUI

struct GameWindow<Content, TitleBar, BottomBar>: View where Content: View, TitleBar: View, BottomBar: View {
    var content: Content
    var titleBar: TitleBar
    var bottomBar: BottomBar

    @Environment(\.displayScale) private var displayScale

    var body: some View {
        VStack(spacing: 0) {
            titleBar

            content
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .overlay(alignment: .leading) {
                    Rectangle().fill(Color.gameBoxBorder).frame(width: 1 / displayScale)
                }
                .overlay(alignment: .trailing) {
                    Rectangle().fill(Color.gameBoxBorder).frame(width: 1 / displayScale)
                }

            bottomBar
        }
    }

    init(
        @ViewBuilder content: () -> Content,
        @ViewBuilder titleBar: () -> TitleBar,
        @ViewBuilder bottomBar: () -> BottomBar
    ) {
        self.content = content()
        self.titleBar = titleBar()
        self.bottomBar = bottomBar()
    }

    init(
        @ViewBuilder content: () -> Content,
        @ViewBuilder titleBar: () -> TitleBar
    ) where BottomBar == GameBottomBar<EmptyView> {
        self.content = content()
        self.titleBar = titleBar()
        self.bottomBar = GameBottomBar()
    }

    init(
        @ViewBuilder content: () -> Content,
        @ViewBuilder bottomBar: () -> BottomBar
    ) where TitleBar == GameTitleBar {
        self.content = content()
        self.titleBar = GameTitleBar()
        self.bottomBar = bottomBar()
    }

    init(
        @ViewBuilder content: () -> Content
    ) where TitleBar == GameTitleBar, BottomBar == GameBottomBar<EmptyView> {
        self.content = content()
        self.titleBar = GameTitleBar()
        self.bottomBar = GameBottomBar()
    }
}
