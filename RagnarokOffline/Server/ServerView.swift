//
//  ServerView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/6.
//

import SwiftUI
import rAthenaLogin
import rAthenaChar
import rAthenaMap
import rAthenaWeb

struct ServerView: View {
    @StateObject private var loginServer = ObservableServer(server: LoginServer.shared)
    @StateObject private var charServer = ObservableServer(server: CharServer.shared)
    @StateObject private var mapServer = ObservableServer(server: MapServer.shared)
    @StateObject private var webServer = ObservableServer(server: WebServer.shared)

    var body: some View {
        List {
            NavigationLink(value: MenuItem.loginServer) {
                LabeledContent {
                    Text(loginServer.status.description)
                        .font(.footnote)
                } label: {
                    Label(loginServer.name, systemImage: "terminal")
                }
            }

            NavigationLink(value: MenuItem.charServer) {
                LabeledContent {
                    Text(charServer.status.description)
                        .font(.footnote)
                } label: {
                    Label(charServer.name, systemImage: "terminal")
                }
            }

            NavigationLink(value: MenuItem.mapServer) {
                LabeledContent {
                    Text(mapServer.status.description)
                        .font(.footnote)
                } label: {
                    Label(mapServer.name, systemImage: "terminal")
                }
            }

            NavigationLink(value: MenuItem.webServer) {
                LabeledContent {
                    Text(webServer.status.description)
                        .font(.footnote)
                } label: {
                    Label(webServer.name, systemImage: "terminal")
                }
            }
        }
        .navigationDestination(for: MenuItem.self) { item in
            switch item {
            case .loginServer:
                ServerTerminalView(server: loginServer)
            case .charServer:
                ServerTerminalView(server: charServer)
            case .mapServer:
                ServerTerminalView(server: mapServer)
            case .webServer:
                ServerTerminalView(server: webServer)
            default:
                EmptyView()
            }
        }
        .navigationTitle("Server")
    }
}

#Preview {
    ServerView()
}
