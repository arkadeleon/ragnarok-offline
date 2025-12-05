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

                        switch loginPhase {
                        case .login:
                            LoginView()
                        case .charServerList(let charServers):
                            CharServerListView(charServers: charServers)
                        case .characterSelect(let characters):
                            CharacterSelectView(characters: characters)
                        case .characterMake(let slot):
                            CharacterMakeView(slot: slot)
                        }
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    LoginFlowView(loginPhase: .login)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(GameSession.testing)
}
