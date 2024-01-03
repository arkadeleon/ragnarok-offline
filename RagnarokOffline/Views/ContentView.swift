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
import rAthenaControl

struct ContentView: View {
    private let servers: [RAServer] = [
        RALoginServer.shared,
        RACharServer.shared,
        RAMapServer.shared,
        RAWebServer.shared,
    ]

    private let databases: [RADatabase] = [
        RAItemDatabase.shared,
        RAMonsterDatabase.shared,
        RAJobDatabase.shared,
        RASkillDatabase.shared,
        RASkillTreeDatabase.shared,
    ]

    var body: some View {
        NavigationView {
            List {
                Section("Client") {
                    NavigationLink {
                        FilesView(file: .directory(ClientBundle.shared.url))
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
                    ForEach(servers, id: \.name) { server in
                        NavigationLink {
                            ServerView(server: server)
                                .ignoresSafeArea()
                                .navigationTitle(server.name)
                                .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            Label(server.name, systemImage: "macpro.gen3.server")
                        }
                    }
                }

                Section("Databases") {
                    NavigationLink {
                        RADatabaseView(database: RAItemDatabase.shared)
                    } label: {
                        Label(RAItemDatabase.shared.name, systemImage: "list.bullet.rectangle")
                    }

                    NavigationLink {
                        RADatabaseView(database: RAMonsterDatabase.shared)
                    } label: {
                        Label(RAMonsterDatabase.shared.name, systemImage: "list.bullet.rectangle")
                    }

                    NavigationLink {
                        RADatabaseView(database: RAJobDatabase.shared)
                    } label: {
                        Label(RAJobDatabase.shared.name, systemImage: "list.bullet.rectangle")
                    }

                    NavigationLink {
                        SkillDatabaseView()
                    } label: {
                        Label(RASkillDatabase.shared.name, systemImage: "list.bullet.rectangle")
                    }

                    NavigationLink {
                        RADatabaseView(database: RASkillTreeDatabase.shared)
                    } label: {
                        Label(RASkillTreeDatabase.shared.name, systemImage: "list.bullet.rectangle")
                    }
                }
            }
            .navigationTitle("Ragnarok Offline")

            FilesView(file: .directory(ClientBundle.shared.url))
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
