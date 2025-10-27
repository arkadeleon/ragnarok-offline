//
//  WalkingSimulatorView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/10/13.
//

import RagnarokGame
import Network
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

    private enum ConnectionState: Equatable {
        case unknown
        case testing
        case available
        case unavailable(NWError)
    }

    @State private var connectionState: ConnectionState = .unknown

    private let serverStartupTip = ServerStartupTip()
    private let accountRegistrationTip = AccountRegistrationTip()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                TipView(serverStartupTip)
                TipView(accountRegistrationTip)

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

                        Task {
                            await startGameSession()
                        }
                    } label: {
                        Text("Start")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(Color.blue.opacity(connectionState == .testing ? 0.5 : 1.0))
                            .cornerRadius(8)
                    }
                    .padding(.top, 8)
                    .disabled(connectionState == .testing)
                }
                .padding(16)
                .background(.background)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)

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
    WalkingSimulatorView()
        .environment(GameSession(resourceManager: .shared))
        .environment(SettingsModel())
}
