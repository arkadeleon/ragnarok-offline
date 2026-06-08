//
//  ContentView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//

import RagnarokGame
import StoreKit
import SwiftUI

struct ContentView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.horizontalSizeClass) private var sizeClass

    @State private var selectedItem: SidebarItem?
    @State private var incomingFile: File?

    var body: some View {
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
        .sheet(item: $incomingFile) { file in
            NavigationStack {
                FilePreviewView(file: file, resourceManager: appModel.resourceManager)
                    .toolbar {
                        ToolbarDoneButton {
                            incomingFile = nil
                        }
                    }
            }
            .presentationSizing(.page)
        }
        .onAppear {
            selectDefaultItemIfNeeded()
        }
        .onChange(of: sizeClass) {
            selectDefaultItemIfNeeded()
        }
        .onOpenURL { url in
            incomingFile = File(node: .regularFile(url), location: .external)
        }
        .subscriptionStatusTask(for: remoteClientSubscriptionGroupID) { taskState in
            var isRemoteClientEnabled: Bool
            if let entitlement = taskState.value {
                isRemoteClientEnabled = entitlement.count(where: { $0.state != .revoked && $0.state != .expired }) > 0
            } else {
                isRemoteClientEnabled = false
            }

            appModel.settings.isRemoteClientEnabled = isRemoteClientEnabled
            await appModel.resourceManager.setRemoteClientEnabled(isRemoteClientEnabled)
        }
    }

    @ViewBuilder private func detailView(for item: SidebarItem) -> some View {
        switch item {
        case .localClientFiles:
            FilesView("Local Client Files", directory: appModel.localClientDirectory)
        case .remoteClientFiles:
            FilesView("Remote Client Files", directory: appModel.remoteClientCacheDirectory)
        case .gameClient:
            GameClientView()
                .environment(appModel.gameSession)
                .environment(appModel.settings)
        case .chatClient:
            ChatClientView()
                .environment(appModel.chatSession)
        case .serverFiles:
            FilesView("Server Files", directory: appModel.serverDirectory)
        case .loginServer:
            ServerView(server: appModel.serverManager.loginServer, serverManager: appModel.serverManager)
        case .charServer:
            ServerView(server: appModel.serverManager.charServer, serverManager: appModel.serverManager)
        case .mapServer:
            ServerView(server: appModel.serverManager.mapServer, serverManager: appModel.serverManager)
        case .webServer:
            ServerView(server: appModel.serverManager.webServer, serverManager: appModel.serverManager)
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
        case .skillSimulator:
            SkillSimulatorView()
                .environment(appModel.skillSimulator)
                .environment(appModel.database)
        case .mapViewer:
            MapViewer(resourceManager: appModel.resourceManager)
                .environment(appModel.database)
        case .effectViewer:
            EffectViewer(resourceManager: appModel.resourceManager)
        case .cube:
            CubeView()
        }
    }

    private func selectDefaultItemIfNeeded() {
        if sizeClass != .compact, selectedItem == nil {
            selectedItem = .localClientFiles
        }
    }
}

extension View {
    func navigationDestinations(appModel: AppModel) -> some View {
        self.navigationDestination(for: File.self) { file in
                if file.hasFiles {
                    FilesView(directory: file)
                } else {
                    FilePreviewView(file: file, resourceManager: appModel.resourceManager)
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
