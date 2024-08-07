//
//  SidebarView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/9.
//

import rAthenaLogin
import rAthenaChar
import rAthenaMap
import rAthenaWeb
import SwiftUI

enum SidebarItem: Hashable {
    case files
    case messages
    case cube
    case server(ObservableServer)
    case serverFiles
    case itemDatabase
    case jobDatabase
    case mapDatabase
    case monsterDatabase
    case monsterSummonDatabase
    case petDatabase
    case skillDatabase
    case statusChangeDatabase
}

struct SidebarView: View {
    var selection: Binding<SidebarItem?>?

    @State private var loginServer = ObservableServer(server: LoginServer.shared)
    @State private var charServer = ObservableServer(server: CharServer.shared)
    @State private var mapServer = ObservableServer(server: MapServer.shared)
    @State private var webServer = ObservableServer(server: WebServer.shared)

    @State private var isDatabaseSectionExpanded = true
    @State private var isSettingsPresented = false

    var body: some View {
        List(selection: selection) {
            Section {
                NavigationLink(value: SidebarItem.files) {
                    Label("Files", systemImage: "folder")
                }

                #if DEBUG
                NavigationLink(value: SidebarItem.messages) {
                    Label("Messages", systemImage: "message")
                }

                NavigationLink(value: SidebarItem.cube) {
                    Label("Cube", systemImage: "cube")
                }
                #endif
            } header: {
                Text("Client")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.primary)
                    .textCase(nil)
            }

            Section {
                NavigationLink(value: SidebarItem.server(loginServer)) {
                    ServerCell(server: loginServer)
                }

                NavigationLink(value: SidebarItem.server(charServer)) {
                    ServerCell(server: charServer)
                }

                NavigationLink(value: SidebarItem.server(mapServer)) {
                    ServerCell(server: mapServer)
                }

                NavigationLink(value: SidebarItem.server(webServer)) {
                    ServerCell(server: webServer)
                }

                #if DEBUG
                NavigationLink(value: SidebarItem.serverFiles) {
                    Label("Server Files", systemImage: "folder")
                }
                #endif
            } header: {
                HStack {
                    Text("Server")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.primary)

                    Spacer()

                    Button {
                        startAllServers()
                    } label: {
                        Label("Start All", systemImage: "play")
                    }
                }
                .textCase(nil)
            }

            Section(isExpanded: $isDatabaseSectionExpanded) {
                NavigationLink(value: SidebarItem.itemDatabase) {
                    Label("Item Database", systemImage: "leaf")
                }

                NavigationLink(value: SidebarItem.jobDatabase) {
                    Label("Job Database", systemImage: "person")
                }

                NavigationLink(value: SidebarItem.mapDatabase) {
                    Label("Map Database", systemImage: "map")
                }

                NavigationLink(value: SidebarItem.monsterDatabase) {
                    Label("Monster Database", systemImage: "pawprint")
                }

                NavigationLink(value: SidebarItem.monsterSummonDatabase) {
                    Label("Monster Summon Database", systemImage: "pawprint")
                }

                NavigationLink(value: SidebarItem.petDatabase) {
                    Label("Pet Database", systemImage: "pawprint")
                }

                NavigationLink(value: SidebarItem.skillDatabase) {
                    Label("Skill Database", systemImage: "arrow.up.heart")
                }

                #if DEBUG
                NavigationLink(value: SidebarItem.statusChangeDatabase) {
                    Label("Status Change Database", systemImage: "moon.zzz")
                }
                #endif
            } header: {
                Text("Database")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.primary)
                    .textCase(nil)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Ragnarok Offline")
        #if DEBUG
        .toolbar {
            Menu {
                Button {
                    isSettingsPresented.toggle()
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .sheet(isPresented: $isSettingsPresented) {
                NavigationStack {
                    SettingsView()
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") {
                                    isSettingsPresented.toggle()
                                }
                            }
                        }
                }
            }
        }
        #endif
    }

    private func startAllServers() {
        loginServer.start()
        charServer.start()
        mapServer.start()
        webServer.start()
    }
}

#Preview {
    SidebarView(selection: nil)
}
