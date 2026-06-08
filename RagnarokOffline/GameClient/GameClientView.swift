//
//  GameClientView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/10/13.
//

import Network
import RagnarokGame
import SwiftUI

struct GameClientView: View {
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

    @FocusState private var focusedField: GameClientView.Field?

    private enum ConnectionState: Equatable {
        case unknown
        case testing
        case available
        case unavailable(NWError)
    }

    @State private var connectionState: ConnectionState = .unknown

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("* This **Game Client** is still in beta. Some windows and buttons may not work yet.")
                    Text("* Before you start, set up your local client files, such as data.grf. You can also use **Remote Client** if your subscription is active.")
                    Text("* Start the **Login Server**, **Char Server**, and **Map Server** first. The **Game Client** cannot log in before these servers are running.")
                    Text("* To create a new account, enter a username that ends with **_M** or **_F**, such as **ragnarok_M**, in the login window.")
                }
                .padding()
                .background(.background.secondary)
                .foregroundStyle(Color.secondary)
                .cornerRadius(12)

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
                    .padding()

                    Divider()
                        .padding(.horizontal)

                    HStack {
                        Text("Server Port")
                            .foregroundColor(.primary)
                        Spacer()
                        TextField(String(), text: $serverPort)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .serverPort)
                            .textFieldStyle(.plain)
                    }
                    .padding()
                }
                .background(.background.secondary)
                .cornerRadius(12)

                Button {
                    focusedField = nil

                    Task {
                        await startGameSession()
                    }
                } label: {
                    Text("Start Game")
                        .font(.title3)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                }
                .adaptiveProminentButtonStyle()
                .disabled(connectionState == .testing)

                if connectionState == .testing {
                    ProgressView()
                }

                if case .unavailable(let error) = connectionState {
                    Text(error.localizedDescription)
                        .foregroundStyle(.red)
                }
            }
            .padding()
        }
        .navigationTitle("Game Client Beta")
        .onAppear {
            serverAddress = settings.serverAddress
            serverPort = settings.serverPort
        }
        .onChange(of: focusedField) { oldValue, newValue in
            if oldValue == GameClientView.Field.serverAddress {
                let regex = /^((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)|[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}|localhost)$/
                if let _ = try? regex.wholeMatch(in: serverAddress) {
                    settings.serverAddress = serverAddress
                } else {
                    serverAddress = settings.serverAddress
                }
            }

            if oldValue == GameClientView.Field.serverPort {
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

    private func startGameSession() async {
        let configuration = GameSession.Configuration(
            serverAddress: settings.serverAddress,
            serverPort: UInt16(settings.serverPort)!
        )

        connectionState = .testing

        let error = await gameSession.test(configuration)

        if let error {
            connectionState = .unavailable(error)
        } else {
            connectionState = .available

            #if os(macOS)
            openWindow(id: gameSession.windowID, value: configuration)
            #else
            gameSession.start(configuration)
            isGameViewPresented = true
            #endif
        }
    }
}

#Preview {
    let appModel = AppModel()

    GameClientView()
        .environment(appModel.gameSession)
        .environment(appModel.settings)
}
