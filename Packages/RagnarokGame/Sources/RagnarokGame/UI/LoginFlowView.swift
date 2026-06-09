//
//  LoginFlowView.swift
//  RagnarokGame
//
//  Created by Leon Li on 2025/12/5.
//

import SwiftUI

struct LoginFlowView: View {
    var loginPhase: GameSession.LoginPhase

    @Environment(GameSession.self) private var gameSession

    var body: some View {
        GeometryReader { proxy in
            ScrollView([.horizontal, .vertical]) {
                ZStack {
                    switch loginPhase {
                    case .login:
                        LoginView()
                    case .loggingIn:
                        LoginLoadingView()
                    case .charServerList(let charServers):
                        CharServerListView(charServers: charServers)
                    case .connectingCharServer:
                        LoginLoadingView()
                    case .characterSelect(let characters):
                        CharacterSelectView(characters: characters)
                    case .characterMake(let slot):
                        CharacterMakeView(slot: slot)
                    case .waitingForMapServer:
                        LoginLoadingView()
                    }

                    ZStack {
                        ForEach(gameSession.errorMessages.reversed()) { errorMessage in
                            MessageBoxView(errorMessage.content) {
                                Button("OK") {
                                    errorMessage.performAction(in: gameSession)
                                }
                                .buttonStyle(.game)
                                .frame(width: 42, height: 20)
                            }
                        }
                    }
                    .offset(y: -120)
                }
                .frame(minWidth: proxy.size.width, minHeight: proxy.size.height)
            }
            .scrollBounceBehavior(.basedOnSize, axes: [.horizontal, .vertical])
        }
        .background {
            GameImage("bgi_temp.bmp") { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            Task {
                await gameSession.loginAudioPlayer.playBGM()
            }
        }
        .onDisappear {
            gameSession.loginAudioPlayer.stopBGM()
        }
    }
}

#Preview {
    LoginFlowView(loginPhase: .login)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.testing)
}
