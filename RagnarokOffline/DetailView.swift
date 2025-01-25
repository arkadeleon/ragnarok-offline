//
//  DetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/9.
//

import rAthenaResources
import ROGame
import SwiftUI

struct DetailView: View {
    var item: SidebarItem

    @State private var clientDirectory = ObservableFile(file: .directory(GameResourceManager.default.baseURL))
    @State private var serverDirectory = ObservableFile(file: .directory(ServerResourceManager.default.workingDirectoryURL))

    var body: some View {
        ZStack {
            switch item {
            case .files:
                FilesView(title: "Files", directory: clientDirectory)
            case .messages:
                MessagesView()
            case .game:
                GameView()
            case .cube:
                RealityCubeView()
            case .character:
                CharacterView()
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
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    DetailView(item: .files)
}
