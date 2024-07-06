//
//  ContentView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//

import SwiftUI
import rAthenaResources
import rAthenaLogin
import rAthenaChar
import rAthenaMap
import rAthenaWeb
import ROClient

enum SidebarItem: Hashable {
    case files
    case messages
    case cube
    case loginServer
    case charServer
    case mapServer
    case webServer
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

struct ContentView: View {
    @State private var clientDirectory = ObservableFile(file: .directory(ClientResourceBundle.shared.url))
    @State private var serverDirectory = ObservableFile(file: .directory(ServerResourceBundle.shared.url))

    @State private var loginServer = ObservableServer(server: LoginServer.shared)
    @State private var charServer = ObservableServer(server: CharServer.shared)
    @State private var mapServer = ObservableServer(server: MapServer.shared)
    @State private var webServer = ObservableServer(server: WebServer.shared)

    @State private var selectedItem: SidebarItem? = .files
    @State private var isDatabaseSectionExpanded = true

    @State private var isSettingsPresented = false

    var body: some View {
        ResponsiveView {
            NavigationStack {
                sidebar(selection: nil)
                    .navigationDestination(for: SidebarItem.self) { item in
                        detail(for: item)
                            #if !os(macOS)
                            .navigationBarTitleDisplayMode(.inline)
                            #endif
                    }
            }
        } regular: {
            NavigationSplitView {
                sidebar(selection: $selectedItem)
            } detail: {
                if let item = selectedItem {
                    NavigationStack {
                        detail(for: item)
                            #if !os(macOS)
                            .navigationBarTitleDisplayMode(.inline)
                            #endif
                    }
                }
            }
        }
        .task {
            await load()
        }
    }

    private func sidebar(selection: Binding<SidebarItem?>?) -> some View {
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
                    .foregroundStyle(Color(uiColor: .label))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .textCase(nil)
            }

            Section {
                NavigationLink(value: SidebarItem.loginServer) {
                    LabeledContent {
                        Text(loginServer.status.localizedStringResource)
                            .font(.footnote)
                    } label: {
                        Label(loginServer.name, systemImage: "terminal")
                    }
                }

                NavigationLink(value: SidebarItem.charServer) {
                    LabeledContent {
                        Text(charServer.status.localizedStringResource)
                            .font(.footnote)
                    } label: {
                        Label(charServer.name, systemImage: "terminal")
                    }
                }

                NavigationLink(value: SidebarItem.mapServer) {
                    LabeledContent {
                        Text(mapServer.status.localizedStringResource)
                            .font(.footnote)
                    } label: {
                        Label(mapServer.name, systemImage: "terminal")
                    }
                }

                NavigationLink(value: SidebarItem.webServer) {
                    LabeledContent {
                        Text(webServer.status.localizedStringResource)
                            .font(.footnote)
                    } label: {
                        Label(webServer.name, systemImage: "terminal")
                    }
                }

                #if DEBUG
                NavigationLink(value: SidebarItem.serverFiles) {
                    Label("Server Files", systemImage: "folder")
                }
                #endif
            } header: {
                HStack {
                    Text("Server")
                        .foregroundStyle(Color(uiColor: .label))
                        .font(.title3)
                        .fontWeight(.semibold)

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
                    .foregroundStyle(Color(uiColor: .label))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .textCase(nil)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Ragnarok Offline")
//        .toolbar {
//            Menu {
//                Button {
//                    isSettingsPresented.toggle()
//                } label: {
//                    Label("Settings", systemImage: "gearshape")
//                }
//            } label: {
//                Image(systemName: "ellipsis.circle")
//            }
//            .sheet(isPresented: $isSettingsPresented) {
//                NavigationStack {
//                    SettingsView()
//                        .toolbar {
//                            ToolbarItem(placement: .confirmationAction) {
//                                Button("Done") {
//                                    isSettingsPresented.toggle()
//                                }
//                            }
//                        }
//                }
//            }
//        }
    }

    private func detail(for item: SidebarItem) -> some View {
        ZStack {
            switch item {
            case .files:
                FilesView(title: "Files", directory: clientDirectory)
            case .messages:
                MessagesView()
            case .cube:
                CubeView()
            case .loginServer:
                ServerTerminalView(server: loginServer)
            case .charServer:
                ServerTerminalView(server: charServer)
            case .mapServer:
                ServerTerminalView(server: mapServer)
            case .webServer:
                ServerTerminalView(server: webServer)
            case .serverFiles:
                FilesView(title: "Server Files", directory: serverDirectory)
            case .itemDatabase:
                ItemDatabaseView()
            case .jobDatabase:
                JobDatabaseView()
            case .mapDatabase:
                MapDatabaseView()
            case .monsterDatabase:
                MonsterDatabaseView()
            case .monsterSummonDatabase:
                MonsterSummonDatabaseView()
            case .petDatabase:
                PetDatabaseView()
            case .skillDatabase:
                SkillDatabaseView()
            case .statusChangeDatabase:
                StatusChangeDatabaseView()
            }
        }
    }

    private func load() async {
        try? await ServerResourceBundle.shared.load()
    }

    private func startAllServers() {
        loginServer.start()
        charServer.start()
        mapServer.start()
        webServer.start()
    }
}
