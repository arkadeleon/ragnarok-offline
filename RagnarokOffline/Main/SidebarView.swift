//
//  SidebarView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/9.
//

import rAthenaResources
import SwiftUI

enum SidebarItem: Hashable {
    case clientFiles
    case clientCachedFiles

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
                NavigationLink(value: SidebarItem.clientFiles) {
                    Label("Local Files", systemImage: "folder")
                }

                NavigationLink(value: SidebarItem.clientCachedFiles) {
                    Label("Cached Files", systemImage: "folder")
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
                    Label("Server Files", systemImage: "folder")
                }
                #endif

                NavigationLink(value: SidebarItem.loginServer) {
                    ServerCell(server: appModel.loginServer)
                }

                NavigationLink(value: SidebarItem.charServer) {
                    ServerCell(server: appModel.charServer)
                }

                NavigationLink(value: SidebarItem.mapServer) {
                    ServerCell(server: appModel.mapServer)
                }

                NavigationLink(value: SidebarItem.webServer) {
                    ServerCell(server: appModel.webServer)
                }
            } header: {
                Text("Server")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.primary)
                    .textCase(nil)
            }
            .sectionActions {
                StartAllServersButton()
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
            }
        }
    }
}

#Preview {
    SidebarView(selection: nil)
}
