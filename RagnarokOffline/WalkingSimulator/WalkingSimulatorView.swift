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
    @Environment(GameSession.self) private var gameSession
    @Environment(SettingsModel.self) private var settings

    #if os(macOS)
    @Environment(\.openWindow) private var openWindow
    #else
    @State private var isGameViewPresented = false
    #endif

    @State private var serverAddress = ""
    @State private var serverPort = ""

    private enum Field: Hashable {
        case serverAddress
        case serverPort
    }

    @FocusState private var focusedField: WalkingSimulatorView.Field?

    private let serverStartupTip = ServerStartupTip()
    private let accountRegistrationTip = AccountRegistrationTip()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                #if !os(macOS)
                TipView(serverStartupTip)
                TipView(accountRegistrationTip)
                #endif

                VStack(spacing: 12) {
                    VStack(spacing: 0) {
                        HStack {
                            Text("Server Address")
                                .foregroundColor(.primary)
                            Spacer()
                            TextField(String(), text: $serverAddress)
                                .multilineTextAlignment(.trailing)
                                .focused($focusedField, equals: .serverAddress)
                                .textFieldStyle(.plain)
                        }
                        .padding(12)

                        Divider()

                        HStack {
                            Text("Server Port")
                                .foregroundColor(.primary)
                            Spacer()
                            TextField(String(), text: $serverPort)
                                .multilineTextAlignment(.trailing)
                                .focused($focusedField, equals: .serverPort)
                                .textFieldStyle(.plain)
                        }
                        .padding(12)
                    }
                    .background(.background.secondary)
                    .cornerRadius(8)

                    Button {
                        focusedField = nil

                        let configuration = GameSession.Configuration(
                            serverAddress: settings.serverAddress,
                            serverPort: settings.serverPort
                        )

                        #if os(macOS)
                        openWindow(id: gameSession.windowID, value: configuration)
                        #else
                        gameSession.start(configuration)
                        isGameViewPresented = true
                        #endif
                    } label: {
                        Text("Start")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .padding(.top, 8)
                }
                .padding(16)
                .background(.background)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
            }
            .padding()
        }
        .navigationTitle("Walking Simulator")
        .onAppear {
            serverAddress = settings.serverAddress
            serverPort = settings.serverPort
        }
        .onChange(of: focusedField) { oldValue, newValue in
            if oldValue == WalkingSimulatorView.Field.serverAddress {
                let regex = /^((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)|[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}|localhost)$/
                if let _ = try? regex.wholeMatch(in: serverAddress) {
                    settings.serverAddress = serverAddress
                } else {
                    serverAddress = settings.serverAddress
                }
            }

            if oldValue == WalkingSimulatorView.Field.serverPort {
                let regex = /^((6553[0-5])|(655[0-2][0-9])|(65[0-4][0-9]{2})|(6[0-4][0-9]{3})|([1-5][0-9]{4})|([0-5]{0,5})|([0-9]{1,4}))$/
                if let _ = try? regex.wholeMatch(in: serverPort) {
                    settings.serverPort = serverPort
                } else {
                    serverPort = settings.serverPort
                }
            }
        }
        #if !os(macOS)
        .fullScreenCover(isPresented: $isGameViewPresented) {
            GameView(gameSession: gameSession) {
                isGameViewPresented = false
                gameSession.stop()
            }
        }
        #endif
    }
}

#Preview {
    WalkingSimulatorView()
        .environment(GameSession(resourceManager: .shared))
        .environment(SettingsModel())
}
