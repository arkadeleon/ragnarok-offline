//
//  ContentView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppModel.self) private var appModel

    @State private var selectedItem: SidebarItem? = .clientFiles
    @State private var incomingFile: File?

    var body: some View {
        AdaptiveView {
            NavigationStack {
                SidebarView(selection: nil)
                    .navigationDestination(for: SidebarItem.self) { item in
                        detailView(for: item)
                            .toolbarTitleDisplayMode(.inline)
                    }
                    .navigationDestinations(appModel: appModel)
            }
        } regular: {
            NavigationSplitView {
                SidebarView(selection: $selectedItem)
            } detail: {
                if let item = selectedItem {
                    NavigationStack {
                        detailView(for: item)
                            .toolbarTitleDisplayMode(.inline)
                            .navigationDestinations(appModel: appModel)
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
            .presentationSizing(.page)
        }
    }

    @ViewBuilder
    private func detailView(for item: SidebarItem) -> some View {
        switch item {
        case .clientFiles:
            FilesView("Local Files", directory: appModel.clientDirectory)
                .environment(appModel.fileSystem)
        case .clientCachedFiles:
            FilesView("Cached Files", directory: appModel.clientCachesDirectory)
                .environment(appModel.fileSystem)
        case .serverFiles:
            FilesView("Server Files", directory: appModel.serverDirectory)
                .environment(appModel.fileSystem)
        case .loginServer:
            ServerView(server: appModel.loginServer)
        case .charServer:
            ServerView(server: appModel.charServer)
        case .mapServer:
            ServerView(server: appModel.mapServer)
        case .webServer:
            ServerView(server: appModel.webServer)
        case .itemDatabase:
            ItemDatabaseView()
                .environment(appModel.itemDatabase)
        case .jobDatabase:
            JobDatabaseView()
                .environment(appModel.jobDatabase)
        case .mapDatabase:
            MapDatabaseView()
                .environment(appModel.mapDatabase)
        case .monsterDatabase:
            MonsterDatabaseView()
                .environment(appModel.monsterDatabase)
        case .monsterSummonDatabase:
            MonsterSummonDatabaseView()
                .environment(appModel.monsterSummonDatabase)
        case .petDatabase:
            PetDatabaseView()
                .environment(appModel.petDatabase)
                .environment(appModel.monsterDatabase)
        case .skillDatabase:
            SkillDatabaseView()
                .environment(appModel.skillDatabase)
        case .statusChangeDatabase:
            StatusChangeDatabaseView()
                .environment(appModel.statusChangeDatabase)
        case .characterSimulator:
            CharacterSimulatorView()
                .environment(appModel.characterSimulator)
                .environment(appModel.itemDatabase)
        case .chat:
            ChatView()
                .environment(appModel.chatSession)
        case .game:
            GameView()
                .environment(appModel.gameSession)
        case .cube:
            CubeView()
        }
    }
}

extension View {
    func navigationDestinations(appModel: AppModel) -> some View {
        self
            .navigationDestination(for: File.self) { file in
                FilesView(directory: file)
                    .environment(appModel.fileSystem)
            }
            .navigationDestination(for: ItemModel.self) { item in
                ItemDetailView(item: item)
                    .environment(appModel.monsterDatabase)
            }
            .navigationDestination(for: JobModel.self) { job in
                JobDetailView(job: job)
            }
            .navigationDestination(for: MapModel.self) { map in
                MapDetailView(map: map)
                    .environment(appModel.monsterDatabase)
            }
            .navigationDestination(for: MonsterModel.self) { monster in
                MonsterDetailView(monster: monster)
                    .environment(appModel.itemDatabase)
                    .environment(appModel.mapDatabase)
            }
            .navigationDestination(for: MonsterSummonModel.self) { monsterSummon in
                MonsterSummonDetailView(monsterSummon: monsterSummon)
                    .environment(appModel.monsterDatabase)
            }
            .navigationDestination(for: PetModel.self) { pet in
                PetDetailView(pet: pet)
                    .environment(appModel.itemDatabase)
            }
            .navigationDestination(for: SkillModel.self) { skill in
                SkillDetailView(skill: skill)
            }
            .navigationDestination(for: StatusChangeModel.self) { statusChange in
                StatusChangeDetailView(statusChange: statusChange)
            }
    }
}
