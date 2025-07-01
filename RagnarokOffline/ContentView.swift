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
    @Environment(\.clientDirectory) private var clientDirectory: File!
    @Environment(\.serverDirectory) private var serverDirectory: File!

    @Environment(\.loginServer) private var loginServer: ServerWrapper!
    @Environment(\.charServer) private var charServer: ServerWrapper!
    @Environment(\.mapServer) private var mapServer: ServerWrapper!
    @Environment(\.webServer) private var webServer: ServerWrapper!

    @State private var selectedItem: SidebarItem? = .clientFiles
    @State private var incomingFile: File?

    var body: some View {
        AsyncContentView(load: load) {
            AdaptiveView {
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
            .onOpenURL { url in
                incomingFile = File(node: .regularFile(url))
            }
            .sheet(item: $incomingFile) { file in
                NavigationStack {
                    FilePreviewTabView(files: [file], currentFile: file) {
                        incomingFile = nil
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func detail(for item: SidebarItem) -> some View {
        switch item {
        case .clientFiles:
            FilesView(title: "Files", directory: clientDirectory)
        case .serverFiles:
            FilesView(title: "Files", directory: serverDirectory)
        case .loginServer:
            ServerView(server: loginServer)
        case .charServer:
            ServerView(server: charServer)
        case .mapServer:
            ServerView(server: mapServer)
        case .webServer:
            ServerView(server: webServer)
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
        case .characterSimulator:
            CharacterSimulatorView()
        case .chat:
            ChatView()
        case .game:
            GameView()
        case .cube:
            RealityCubeView()
        }
    }

    private func load() async throws {
        do {
            try ServerResourceManager.default.prepareWorkingDirectory()
        } catch {
            logger.warning("\(error.localizedDescription)")
        }
    }
}
