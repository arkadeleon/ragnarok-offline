//
//  GameWindow.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/11.
//

import SwiftUI

struct GameWindow<Content, BottomBar>: View where Content: View, BottomBar: View {
    var content: Content
    var bottomBar: BottomBar

    @Environment(\.gameWindowTitle) private var title
    @Environment(\.gameWindowCloseAction) private var closeAction

    var body: some View {
        VStack(spacing: 0) {
            GameTitleBar(title, closeAction: closeAction)

            content
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .overlay(alignment: .leading) {
                    Rectangle().fill(Color.gameBoxBorder).frame(width: 1)
                }
                .overlay(alignment: .trailing) {
                    Rectangle().fill(Color.gameBoxBorder).frame(width: 1)
                }

            bottomBar
        }
    }

    init(
        @ViewBuilder content: () -> Content,
        @ViewBuilder bottomBar: () -> BottomBar
    ) {
        self.content = content()
        self.bottomBar = bottomBar()
    }

    init(
        @ViewBuilder content: () -> Content
    ) where BottomBar == GameBottomBar<EmptyView> {
        self.content = content()
        self.bottomBar = GameBottomBar()
    }
}

extension EnvironmentValues {
    @Entry var gameWindowTitle: Text?
    @Entry var gameWindowCloseAction: (() -> Void)?
}

extension View {
    nonisolated func gameWindowTitle(_ title: Text) -> some View {
        environment(\.gameWindowTitle, title)
    }

    nonisolated func gameWindowCloseAction(_ closeAction: @escaping () -> Void) -> some View {
        environment(\.gameWindowCloseAction, closeAction)
    }
}
