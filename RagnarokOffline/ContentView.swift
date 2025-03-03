//
//  ContentView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//

import rAthenaResources
import ROResources
import SwiftUI

struct ContentView: View {
    @State private var selectedItem: SidebarItem? = .files

    @State private var clientDirectory = File(node: .directory(ResourceManager.default.baseURL))
    @State private var serverDirectory = File(node: .directory(ServerResourceManager.default.workingDirectoryURL))

    @State private var conversation = Conversation()
    @State private var gameSession = GameSession()

    var body: some View {
        AsyncContentView(load: load) {
            ResponsiveView {
                NavigationStack {
                    SidebarView(selection: nil)
                        .navigationDestination(for: SidebarItem.self) { item in
                            detail(for: item)
                                .toolbarTitleDisplayMode(.inline)
                        }
                }
            } regular: {
                NavigationSplitView {
                    SidebarView(selection: $selectedItem)
                } detail: {
                    if let item = selectedItem {
                        NavigationStack {
                            detail(for: item)
                                .toolbarTitleDisplayMode(.inline)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func detail(for item: SidebarItem) -> some View {
        switch item {
        case .files:
            FilesView(title: "Files", directory: clientDirectory)
        case .messages:
            MessagesView(conversation: conversation)
        case .game:
            GameView(gameSession: gameSession)
        case .cube:
            RealityCubeView()
        case .characterSimulator:
            CharacterSimulatorView()
        case .loginServer:
            ServerView(server: .login)
        case .charServer:
            ServerView(server: .char)
        case .mapServer:
            ServerView(server: .map)
        case .webServer:
            ServerView(server: .web)
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

    private func load() async throws {
        try ServerResourceManager.default.prepareWorkingDirectory()
    }
}
