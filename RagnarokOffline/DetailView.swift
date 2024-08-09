//
//  DetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/8/9.
//

import rAthenaResources
import ROClient
import SwiftUI

struct DetailView: View {
    var item: SidebarItem

    @State private var clientDirectory = ObservableFile(file: .directory(ClientResourceBundle.shared.url))
    @State private var serverDirectory = ObservableFile(file: .directory(ServerResourceBundle.shared.url))

    var body: some View {
        ZStack {
            switch item {
            case .files:
                FilesView(title: "Files", directory: clientDirectory)
            case .messages:
                MessagesView()
            case .cube:
                CubeView()
            case .loginServer(let loginServer):
                LoginServerView(loginServer: loginServer)
            case .charServer(let charServer):
                CharServerView(charServer: charServer)
            case .mapServer(let mapServer):
                MapServerView(mapServer: mapServer)
            case .webServer(let webServer):
                WebServerView(webServer: webServer)
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
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    DetailView(item: .files)
}
