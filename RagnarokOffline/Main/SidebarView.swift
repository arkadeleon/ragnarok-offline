//
//  SidebarView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/9.
//

import rAthenaResources
import SwiftUI

enum SidebarItem: Hashable {
    case clientLocalFiles
    case clientSyncedFiles(File)
    case clientCachedFiles
    case gameClient
    case chatClient

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
    case cube
}

struct SidebarView: View {
    var selection: Binding<SidebarItem?>?

    @Environment(AppModel.self) private var appModel

    @AppStorage("clientSectionExpanded") private var isClientSectionExpanded = true
    @AppStorage("serverSectionExpanded") private var isServerSectionExpanded = true
    @AppStorage("databaseSectionExpanded") private var isDatabaseSectionExpanded = true
    @AppStorage("toolsSectionExpanded") private var isToolsSectionExpanded = true

    @State private var isHelpPresented = false
    @State private var isSettingsPresented = false

    var body: some View {
        List(selection: selection) {
            Section(isExpanded: $isClientSectionExpanded) {
                NavigationLink(value: SidebarItem.clientLocalFiles) {
                    SidebarRow("Local Files", iconName: "folder.fill", iconColor: .blue)
                }

                if let clientSyncedDirectory = appModel.clientSyncedDirectory {
                    NavigationLink(value: SidebarItem.clientSyncedFiles(clientSyncedDirectory)) {
                        SidebarRow("Synced Files", iconName: "folder.fill", iconColor: .blue)
                    }
                }

                NavigationLink(value: SidebarItem.clientCachedFiles) {
                    SidebarRow("Cached Files", iconName: "folder.fill", iconColor: .blue)
                }

                NavigationLink(value: SidebarItem.gameClient) {
                    SidebarRow("Game Client", iconName: "ipad.and.iphone", iconColor: .green)
                }

                #if CHAT_CLIENT_FEATURE
                NavigationLink(value: SidebarItem.chatClient) {
                    SidebarRow("Chat Client", iconName: "message.fill", iconColor: .green)
                }
                #endif
            } header: {
                Text("Client")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.primary)
                    .textCase(nil)
            }

            Section(isExpanded: $isServerSectionExpanded) {
                NavigationLink(value: SidebarItem.serverFiles) {
                    SidebarRow("Server Files", iconName: "folder.fill", iconColor: .blue)
                }

                NavigationLink(value: SidebarItem.loginServer) {
                    SidebarServerRow(server: appModel.loginServer)
                }

                NavigationLink(value: SidebarItem.charServer) {
                    SidebarServerRow(server: appModel.charServer)
                }

                NavigationLink(value: SidebarItem.mapServer) {
                    SidebarServerRow(server: appModel.mapServer)
                }

                NavigationLink(value: SidebarItem.webServer) {
                    SidebarServerRow(server: appModel.webServer)
                }
            } header: {
                Text("Server")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.primary)
                    .textCase(nil)
            }
            .sectionActions {
                Button {
                    Task {
                        try await startAllServers()
                    }
                } label: {
                    SidebarRow("Start All Servers", iconName: "play.fill", iconColor: .gray)
                }
            }

            Section(isExpanded: $isDatabaseSectionExpanded) {
                NavigationLink(value: SidebarItem.itemDatabase) {
                    SidebarRow("Item Database", iconName: "leaf.fill", iconColor: .green)
                }

                NavigationLink(value: SidebarItem.jobDatabase) {
                    SidebarRow("Job Database", iconName: "person.fill", iconColor: .cyan)
                }

                NavigationLink(value: SidebarItem.mapDatabase) {
                    SidebarRow("Map Database", iconName: "map.fill", iconColor: .brown)
                }

                NavigationLink(value: SidebarItem.monsterDatabase) {
                    SidebarRow("Monster Database", iconName: "pawprint.fill", iconColor: .red)
                }

                NavigationLink(value: SidebarItem.monsterSummonDatabase) {
                    SidebarRow("Monster Summon Database", iconName: "pawprint.fill", iconColor: .red)
                }

                NavigationLink(value: SidebarItem.petDatabase) {
                    SidebarRow("Pet Database", iconName: "pawprint.fill", iconColor: .pink)
                }

                NavigationLink(value: SidebarItem.skillDatabase) {
                    SidebarRow("Skill Database", iconName: "arrow.up.heart.fill", iconColor: .purple)
                }

                #if DEBUG
                NavigationLink(value: SidebarItem.statusChangeDatabase) {
                    SidebarRow("Status Change Database", iconName: "moon.zzz.fill", iconColor: .indigo)
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
                    SidebarRow("Character Simulator", iconName: "person.fill", iconColor: .cyan)
                }

                #if DEBUG
                NavigationLink(value: SidebarItem.cube) {
                    SidebarRow("Cube", iconName: "cube.fill", iconColor: .orange)
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
        .toolbar {
            Menu {
                Button {
                    isHelpPresented.toggle()
                } label: {
                    Label("Help", systemImage: "questionmark.circle")
                }

                #if DEBUG
                Button {
                    isSettingsPresented.toggle()
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
                #endif
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
        .sheet(isPresented: $isHelpPresented) {
            NavigationStack {
                HelpView {
                    isHelpPresented.toggle()
                }
            }
        }
        .sheet(isPresented: $isSettingsPresented) {
            NavigationStack {
                SettingsView {
                    isSettingsPresented.toggle()
                }
                .environment(appModel.settings)
            }
        }
    }

    private func startAllServers() async throws {
        let serverResourceManager = ServerResourceManager()
        try await serverResourceManager.prepareWorkingDirectory(at: serverWorkingDirectoryURL)

        async let startLoginServer = appModel.loginServer.start()
        async let startCharServer = appModel.charServer.start()
        async let startMapServer = appModel.mapServer.start()
        async let startWebServer = appModel.webServer.start()

        _ = await (startLoginServer, startCharServer, startMapServer, startWebServer)
    }
}

#Preview {
    NavigationStack {
        SidebarView(selection: nil)
    }
    .environment(AppModel())
}
