//
//  WalkingSimulatorView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/10/13.
//

import GameCore
import GameView
import SwiftUI
import TipKit

struct WalkingSimulatorView: View {
    #if os(macOS)
    @Environment(\.openWindow) private var openWindow
    #endif

    @Environment(GameSession.self) private var gameSession

    #if !os(macOS)
    @State private var isGameViewPresented = false
    #endif

    private let serverStartupTip = ServerStartupTip()
    private let accountRegistrationTip = AccountRegistrationTip()

    var body: some View {
        VStack(spacing: 20) {
            TipView(serverStartupTip)

            TipView(accountRegistrationTip)

            Button {
                #if os(macOS)
                openWindow(id: gameSession.windowID)
                #else
                isGameViewPresented = true
                #endif
            } label: {
                Text("Start")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
        .navigationTitle("Walking Simulator")
        #if !os(macOS)
        .fullScreenCover(isPresented: $isGameViewPresented) {
            GameView(gameSession: gameSession) {
                isGameViewPresented = false
            }
        }
        #endif
    }
}

#Preview {
    WalkingSimulatorView()
        .environment(GameSession(serverAddress: "127.0.0.1", serverPort: "6900", resourceManager: .shared))
}
