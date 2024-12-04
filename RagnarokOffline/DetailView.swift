//
//  DetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/9.
//

import ROClientResources
import ROGame
import SwiftUI
import rAthenaResources

struct DetailView: View {
    var item: SidebarItem

    @Environment(\.loginServer) private var loginServer
    @Environment(\.charServer) private var charServer
    @Environment(\.mapServer) private var mapServer
    @Environment(\.webServer) private var webServer

    @State private var clientDirectory = ObservableFile(file: .directory(ClientResourceManager.default.baseURL))
    @State private var serverDirectory = ObservableFile(file: .directory(ServerResourceManager.default.baseURL))

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
            case .loginServer:
                ServerView(server: loginServer)
            case .charServer:
                ServerView(server: charServer)
            case .mapServer:
                ServerView(server: mapServer)
            case .webServer:
                ServerView(server: webServer)
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
