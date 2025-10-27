//
//  GameView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2024/9/5.
//

import SwiftUI

public struct GameView: View {
    public var gameSession: GameSession
    public var onExit: () -> Void

    public var body: some View {
        Group {
            if showsBackground {
                GeometryReader { proxy in
                    ScrollView([.horizontal, .vertical]) {
                        ZStack {
                            GameImage("bgi_temp.bmp") { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: proxy.size.width, height: proxy.size.height)
                            }

                            VStack(spacing: 0) {
                                ForEach(gameSession.errorMessages.reversed()) { errorMessage in
                                    MessageBoxView(errorMessage.content)
                                        .overlay(alignment: .bottomTrailing) {
                                            HStack(spacing: 3) {
                                                GameButton("btn_ok.bmp") {
                                                    gameSession.removeErrorMessage(errorMessage)
                                                }
                                            }
                                            .padding(.horizontal, 5)
                                            .padding(.vertical, 4)
                                        }
                                }

                                contentView
                            }
                        }
                    }
                }
                .ignoresSafeArea()
            } else {
                contentView
            }
        }
        .environment(gameSession)
        .environment(\.exitGame, ExitGameAction(action: onExit))
        #if os(iOS)
        .statusBarHidden()
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        #endif
    }

    private var showsBackground: Bool {
        switch gameSession.phase {
        case .login, .charServerList, .charSelect, .charMake:
            true
        case .mapLoading, .map:
            false
        }
    }

    @ViewBuilder private var contentView: some View {
        switch gameSession.phase {
        case .login:
            LoginView()
        case .charServerList(let charServers):
            CharServerListView(charServers: charServers)
        case .charSelect(let chars):
            CharSelectView(chars: chars)
        case .charMake(let slot):
            CharMakeView(slot: slot)
        case .mapLoading:
            MapLoadingView(progress: 0)
        case .map(let scene):
            MapView(scene: scene)
        }
    }

    public init(gameSession: GameSession, onExit: @escaping () -> Void) {
        self.gameSession = gameSession
        self.onExit = onExit
    }
}

#Preview {
    GameView(gameSession: .testing) {
    }
}
