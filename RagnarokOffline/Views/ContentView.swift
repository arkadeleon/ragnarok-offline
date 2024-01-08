//
//  ContentView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/1/13.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaLogin
import rAthenaChar
import rAthenaMap
import rAthenaWeb

struct ContentView: View {
    private let filesView = FilesView(file: .directory(ClientBundle.shared.url))
    private let serverViews: [ServerView] = [
        ServerView(server: RALoginServer.shared),
        ServerView(server: RACharServer.shared),
        ServerView(server: RAMapServer.shared),
        ServerView(server: RAWebServer.shared),
    ]

    var body: some View {
        NavigationView {
            List {
                Section("Client") {
                    NavigationLink {
                        filesView
                            .ignoresSafeArea()
                            .navigationTitle("Files")
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Label("Files", systemImage: "folder")
                    }

//                    NavigationLink {
//                        GameView()
//                            .ignoresSafeArea()
//                            .navigationTitle("Game")
//                            .navigationBarTitleDisplayMode(.inline)
//                    } label: {
//                        Label("Game", systemImage: "gamecontroller")
//                    }
                }

                Section("Servers") {
                    ForEach(serverViews, id: \.server.name) { serverView in
                        NavigationLink {
                            serverView
                                .ignoresSafeArea()
                                .navigationTitle(serverView.server.name)
                                .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            Label(serverView.server.name, systemImage: "macpro.gen3.server")
                        }
                    }
                }

                Section("Databases") {
                    NavigationLink {
                        ItemDatabaseView()
                    } label: {
                        Label(RAItemDatabase.shared.name, systemImage: "leaf")
                    }

                    NavigationLink {
                        MonsterDatabaseView()
                    } label: {
                        Label(RAMonsterDatabase.shared.name, systemImage: "pawprint")
                    }

                    NavigationLink {
                        JobDatabaseView()
                    } label: {
                        Label(RAJobDatabase.shared.name, systemImage: "person")
                    }

                    NavigationLink {
                        SkillDatabaseView()
                    } label: {
                        Label(RASkillDatabase.shared.name, systemImage: "arrow.up.heart")
                    }
                }
            }
            .navigationTitle("Ragnarok Offline")

            filesView
                .ignoresSafeArea()
                .navigationTitle("Files")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
