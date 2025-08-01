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
                    .navigationDestinationsForModels()
            }
        } regular: {
            NavigationSplitView {
                SidebarView(selection: $selectedItem)
            } detail: {
                if let item = selectedItem {
                    NavigationStack {
                        detailView(for: item)
                            .toolbarTitleDisplayMode(.inline)
                            .navigationDestinationsForModels()
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
            FilesView(title: "Files", directory: appModel.clientDirectory)
        case .clientCachedFiles:
            FilesView(title: "Cached Files", directory: appModel.clientCachesDirectory)
        case .serverFiles:
            FilesView(title: "Files", directory: appModel.serverDirectory)
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
}

extension View {
    func navigationDestinationsForModels() -> some View {
        self
            .navigationDestination(for: File.self) { file in
                FilesView(title: file.name, directory: file)
            }
            .navigationDestination(for: ItemModel.self) { item in
                ItemDetailView(item: item)
            }
            .navigationDestination(for: JobModel.self) { job in
                JobDetailView(job: job)
            }
            .navigationDestination(for: MapModel.self) { map in
                MapDetailView(map: map)
            }
            .navigationDestination(for: MonsterModel.self) { monster in
                MonsterDetailView(monster: monster)
            }
            .navigationDestination(for: MonsterSummonModel.self) { monsterSummon in
                MonsterSummonDetailView(monsterSummon: monsterSummon)
            }
            .navigationDestination(for: PetModel.self) { pet in
                PetDetailView(pet: pet)
            }
            .navigationDestination(for: SkillModel.self) { skill in
                SkillDetailView(skill: skill)
            }
            .navigationDestination(for: StatusChangeModel.self) { statusChange in
                StatusChangeDetailView(statusChange: statusChange)
            }
    }
}
