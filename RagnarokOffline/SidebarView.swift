//
//  SidebarView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/9.
//

import SwiftUI

enum SidebarItem: Hashable {
    case clientFiles

    case serverFiles
    case loginServer
    case charServer
    case mapServer
    case webServer

    case itemDatabase
    case jobDatabase
    case mapDatabase
    case monsterDatabase
    case monsterSummonDatabase
    case petDatabase
    case skillDatabase
    case statusChangeDatabase

    case characterSimulator
    case chat
    case game
    case cube
}

struct SidebarView: View {
    var selection: Binding<SidebarItem?>?

    @Environment(\.loginServer) private var loginServer: ServerWrapper!
    @Environment(\.charServer) private var charServer: ServerWrapper!
    @Environment(\.mapServer) private var mapServer: ServerWrapper!
    @Environment(\.webServer) private var webServer: ServerWrapper!

    @State private var isClientSectionExpanded = true
    @State private var isServerSectionExpanded = true
    @State private var isDatabaseSectionExpanded = true
    @State private var isToolsSectionExpanded = true
    @State private var isSettingsPresented = false

    var body: some View {
        List(selection: selection) {
            Section(isExpanded: $isClientSectionExpanded) {
                NavigationLink(value: SidebarItem.clientFiles) {
                    Label("Files", systemImage: "folder")
                }
            } header: {
                Text("Client")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.primary)
                    .textCase(nil)
            }

            Section(isExpanded: $isServerSectionExpanded) {
                #if DEBUG
                NavigationLink(value: SidebarItem.serverFiles) {
                    Label("Files", systemImage: "folder")
                }
                #endif

                NavigationLink(value: SidebarItem.loginServer) {
                    ServerCell(server: loginServer)
                }

                NavigationLink(value: SidebarItem.charServer) {
                    ServerCell(server: charServer)
                }

                NavigationLink(value: SidebarItem.mapServer) {
                    ServerCell(server: mapServer)
                }

                NavigationLink(value: SidebarItem.webServer) {
                    ServerCell(server: webServer)
                }

                Button {
                    Task {
                        await startAllServers()
                    }
                } label: {
                    Label("Start All Servers", systemImage: "play")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.link)
            } header: {
                Text("Server")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.primary)
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

            Section(isExpanded: $isToolsSectionExpanded) {
                NavigationLink(value: SidebarItem.characterSimulator) {
                    Label("Character Simulator", systemImage: "person")
                }

                #if DEBUG
                NavigationLink(value: SidebarItem.chat) {
                    Label("Chat", systemImage: "message")
                }

                NavigationLink(value: SidebarItem.game) {
                    Label("Game", systemImage: "macwindow")
                }

                NavigationLink(value: SidebarItem.cube) {
                    Label("Cube", systemImage: "cube")
                }
                #endif
            } header: {
                Text("Tools")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.primary)
                    .textCase(nil)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle(String("Ragnarok Offline"))
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
                    SettingsView {
                        isSettingsPresented.toggle()
                    }
                }
            }
        }
        #endif
    }

    private func startAllServers() async {
        await withTaskGroup(of: Bool.self) { taskGroup in
            taskGroup.addTask {
                await loginServer.start()
            }
            taskGroup.addTask {
                await charServer.start()
            }
            taskGroup.addTask {
                await mapServer.start()
            }
            taskGroup.addTask {
                await webServer.start()
            }
        }
    }
}

#Preview {
    SidebarView(selection: nil)
}
