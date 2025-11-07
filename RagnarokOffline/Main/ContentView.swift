//
//  ContentView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//

import RagnarokGame
import SwiftUI

struct ContentView: View {
    @Environment(AppModel.self) private var appModel

    @State private var selectedItem: SidebarItem? = .clientLocalFiles
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
            incomingFile = File(node: .regularFile(url), location: .external)
        }
        .sheet(item: $incomingFile) { file in
            NavigationStack {
                FilePreviewView(file: file)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                incomingFile = nil
                            }
                        }
                    }
            }
            .presentationSizing(.page)
        }
    }

    @ViewBuilder
    private func detailView(for item: SidebarItem) -> some View {
        switch item {
        case .clientLocalFiles:
            FilesView("Local Files", directory: appModel.clientLocalDirectory)
        case .clientSyncedFiles(let directory):
            FilesView("Synced Files", directory: directory)
        case .clientCachedFiles:
            FilesView("Cached Files", directory: appModel.clientCachedDirectory)
        case .gameClient:
            #if GAME_CLIENT_FEATURE
            GameClientView()
                .environment(appModel.gameSession)
                .environment(appModel.settings)
            #else
            GameClientIntroView()
            #endif
        case .chatClient:
            ChatClientView()
                .environment(appModel.chatSession)
        case .serverFiles:
            FilesView("Server Files", directory: appModel.serverDirectory)
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
                .environment(appModel.database)
        case .jobDatabase:
            JobDatabaseView()
                .environment(appModel.database)
        case .mapDatabase:
            MapDatabaseView()
                .environment(appModel.database)
        case .monsterDatabase:
            MonsterDatabaseView()
                .environment(appModel.database)
        case .monsterSummonDatabase:
            MonsterSummonDatabaseView()
                .environment(appModel.database)
        case .petDatabase:
            PetDatabaseView()
                .environment(appModel.database)
        case .skillDatabase:
            SkillDatabaseView()
                .environment(appModel.database)
        case .statusChangeDatabase:
            StatusChangeDatabaseView()
                .environment(appModel.database)
        case .characterSimulator:
            CharacterSimulatorView()
                .environment(appModel.characterSimulator)
                .environment(appModel.database)
        case .cube:
            CubeView()
        }
    }
}

extension View {
    func navigationDestinations(appModel: AppModel) -> some View {
        self
            .navigationDestination(for: File.self) { file in
                if file.hasFiles {
                    FilesView(directory: file)
                } else {
                    FilePreviewView(file: file)
                }
            }
            .navigationDestination(for: FileGroup.self) { fileGroup in
                FileGroupView(group: fileGroup)
            }
            .navigationDestination(for: ItemModel.self) { item in
                ItemDetailView(item: item)
                    .environment(appModel.database)
            }
            .navigationDestination(for: JobModel.self) { job in
                JobDetailView(job: job)
                    .environment(appModel.database)
            }
            .navigationDestination(for: MapModel.self) { map in
                MapDetailView(map: map)
                    .environment(appModel.database)
            }
            .navigationDestination(for: MonsterModel.self) { monster in
                MonsterDetailView(monster: monster)
                    .environment(appModel.database)
            }
            .navigationDestination(for: MonsterSummonModel.self) { monsterSummon in
                MonsterSummonDetailView(monsterSummon: monsterSummon)
                    .environment(appModel.database)
            }
            .navigationDestination(for: PetModel.self) { pet in
                PetDetailView(pet: pet)
                    .environment(appModel.database)
            }
            .navigationDestination(for: SkillModel.self) { skill in
                SkillDetailView(skill: skill)
                    .environment(appModel.database)
            }
            .navigationDestination(for: StatusChangeModel.self) { statusChange in
                StatusChangeDetailView(statusChange: statusChange)
                    .environment(appModel.database)
            }
    }
}
